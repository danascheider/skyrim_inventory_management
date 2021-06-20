# frozen_string_literal: true

class ShoppingList < ApplicationRecord
  belongs_to :user
  has_many :shopping_list_items, dependent: :destroy

  validate :one_master_list_per_user
  validates :title, uniqueness: { scope: :user_id }

  before_create :set_default_title, if: :master_or_title_blank?
  after_create :ensure_master_list_present
  before_destroy :ensure_not_master, if: :other_lists_present?
  after_destroy :destroy_master_list, unless: :other_lists_present?

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
