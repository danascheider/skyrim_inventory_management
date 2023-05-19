# frozen_string_literal: true

class AddQuestRewardToCanonicalModels < ActiveRecord::Migration[7.0]
  def change
    add_column :canonical_armors, :quest_reward, :boolean, default: false
    add_column :canonical_books, :quest_reward, :boolean, default: false
    add_column :canonical_clothing_items, :quest_reward, :boolean, default: false
    add_column :canonical_jewelry_items, :quest_reward, :boolean, default: false
    add_column :canonical_misc_items, :quest_reward, :boolean, default: false
    add_column :canonical_potions, :quest_reward, :boolean, default: false
    add_column :canonical_staves, :quest_reward, :boolean, default: false
    add_column :canonical_weapons, :quest_reward, :boolean, default: false
  end
end
