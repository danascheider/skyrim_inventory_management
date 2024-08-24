# frozen_string_literal: true

class AddAddOnToPowers < ActiveRecord::Migration[7.2]
  def change
    add_column :powers, :add_on, :string
  end
end
