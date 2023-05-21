# frozen_string_literal: true

class RenameCanonicalEnchantablesEnchantments < ActiveRecord::Migration[7.0]
  def change
    rename_table :canonical_enchantables_enchantments, :enchantables_enchantments
  end
end
