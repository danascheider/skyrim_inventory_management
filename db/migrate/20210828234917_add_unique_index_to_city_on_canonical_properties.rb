# frozen_string_literal: true

class AddUniqueIndexToCityOnCanonicalProperties < ActiveRecord::Migration[6.1]
  def change
    add_index :canonical_properties, :city, unique: true
  end
end
