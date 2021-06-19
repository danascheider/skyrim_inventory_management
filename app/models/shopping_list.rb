# frozen_string_literal: true

class ShoppingList < ApplicationRecord
  belongs_to :user
  has_many :shopping_list_items, dependent: :destroy

  validate :one_master_list_per_user
  validates :title, uniqueness: { scope: :user_id }

  before_create :set_default_title, if: :master_or_title_blank?
  after_create :ensure_master_list_present

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
end
