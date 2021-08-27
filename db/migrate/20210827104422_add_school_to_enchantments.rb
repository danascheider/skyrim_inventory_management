# frozen_string_literal: true

class AddSchoolToEnchantments < ActiveRecord::Migration[6.1]
  def change
    add_column :enchantments, :school, :string
  end
end
