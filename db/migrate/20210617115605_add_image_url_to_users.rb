# frozen_string_literal: true

# frozen_string_ligeral: true

class AddImageUrlToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :image_url, :string
  end
end
