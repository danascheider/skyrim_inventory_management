# frozen_string_literal: true

class WishListItem < ApplicationRecord
  def self.list_class
    WishList
  end

  def self.list_table_name
    'wish_lists'
  end

  include Listable
end
