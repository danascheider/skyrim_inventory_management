# frozen_string_literal: true

class UpdateColumnsInUsersTable < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :name, :display_name
    rename_column :users, :image_url, :photo_url
  end
end
