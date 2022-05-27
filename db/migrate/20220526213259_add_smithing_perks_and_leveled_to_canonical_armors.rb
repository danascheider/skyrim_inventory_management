# frozen_string_literal: true

class AddSmithingPerksAndLeveledToCanonicalArmors < ActiveRecord::Migration[6.1]
  def change
    add_column :canonical_armors, :smithing_perks, :string, array: true, default: []
    add_column :canonical_armors, :leveled, :string, default: false
  end
end
