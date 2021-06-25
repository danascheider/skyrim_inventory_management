# frozen_string_literal: true

require 'titlecase'

class ShoppingList < ApplicationRecord
  belongs_to :user
  has_many :shopping_list_items, dependent: :destroy

  validate :one_master_list_per_user
  validate :only_master_list_named_master

  # Titles have to be unique per user as described in the API docs. They also can only
  # contain alphanumeric characters and spaces with no special characters or whitespace
  # other than spaces. Leading or trailing whitespace is stripped anyway so the validation
  # ignores any leading or trailing whitespace characters.
  validates :title, uniqueness: { scope: :user_id },
                    format: {
                      with: /\A\s*[a-z0-9 ]*\s*\z/i,
                      message: 'can only include alphanumeric characters and spaces'
                    }

  before_save :set_default_title, if: :master_or_title_blank?
  before_save :titleize_title
  after_create :ensure_master_list_present
  before_destroy :ensure_not_master, if: :other_lists_present?
  after_destroy :destroy_master_list, unless: :other_lists_present?

  scope :master_first, -> { order(master: :desc) }


  def to_json(opts = {})
    opts.merge!({ include: :shopping_list_items }) unless opts.has_key?(:include)
    super(opts)
  end

  private

  def one_master_list_per_user
    if master == true && user.master_shopping_list && user.master_shopping_list != self
      errors.add(:master, 'user can only have one master shopping list')
    end
  end

  def only_master_list_named_master
    errors.add(:title, "cannot be \"#{title}\" for a regular shopping list") if title =~ /^master$/i && !master
  end

  def ensure_master_list_present
    if user.master_shopping_list.nil?
      user.shopping_lists.create!(master: true, title: 'Master')
    end
  end

  def set_default_title
    self.title = if master == true
      'Master'
    else
      highest_number = user.shopping_lists.where("title like '%My List%'").pluck(:title).map { |title| title.gsub('My List ', '').to_i }.max || 0
      "My List #{highest_number + 1}"
    end
  end
  
  def titleize_title
    self.title = Titlecase.titleize(title.strip)
  end

  def master_or_title_blank?
    master == true || title.blank?
  end

  def ensure_not_master
    throw :abort if master == true
  end

  def destroy_master_list
    user.master_shopping_list&.destroy!
  end

  def other_lists_present?
    user.shopping_lists.where(master: false).count > 0
  end
end
