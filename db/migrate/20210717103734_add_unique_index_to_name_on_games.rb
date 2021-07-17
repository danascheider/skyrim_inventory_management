# frozen_string_literal: true

class AddUniqueIndexToNameOnGames < ActiveRecord::Migration[6.1]
  def change
    add_index :games, %i[name user_id], unique: true
  end
end
