# frozen_string_literal: true

class RemoveUniqueIndexFromUserEmail < ActiveRecord::Migration[7.0]
  def change
    remove_index :users, :email, unique: true
  end
end
