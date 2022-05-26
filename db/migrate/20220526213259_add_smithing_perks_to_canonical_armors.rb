# frozen_string_literal: true

class AddSmithingPerksToCanonicalArmors < ActiveRecord::Migration[6.1]
  def change
    add_column :canonical_armors, :smithing_perks, :string, array: true, default: []
  end
end
