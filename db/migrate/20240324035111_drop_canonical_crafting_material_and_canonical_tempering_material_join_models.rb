# frozen_string_literal: true

class DropCanonicalCraftingMaterialAndCanonicalTemperingMaterialJoinModels < ActiveRecord::Migration[7.1]
  def change
    # Remove the Canonical::CraftablesCraftingMaterials and
    # Canonical::TemperablesTemperingMaterials models as we are
    # refactoring to use only the Canonical::Material model
    drop_table :canonical_craftables_crafting_materials
    drop_table :canonical_temperables_tempering_materials

    # Add the `quantity` value that was previously in the join models
    # removed in this migration
    add_column :canonical_materials, :quantity, :integer, null: false

    # Add new polymorphic keys to link materials to items that can be
    # crafted or tempered with them
    add_reference :canonical_materials, :craftable, polymorphic: true, index: true
    add_reference :canonical_materials, :temperable, polymorphic: true, index: true

    # Remove polymorphic `joinable` association, which was for associating
    # another join model, which we no longer need to do
    remove_reference :canonical_materials, :joinable, polymorphic: true, index: true
  end
end
