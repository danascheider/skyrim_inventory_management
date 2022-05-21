# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_05_21_032400) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alchemical_properties", force: :cascade do |t|
    t.string "name", null: false
    t.string "strength_unit"
    t.boolean "effects_cumulative", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_alchemical_properties_on_name", unique: true
  end

  create_table "canonical_armors", force: :cascade do |t|
    t.string "name", null: false
    t.string "item_code", null: false
    t.string "weight", null: false
    t.string "body_slot", null: false
    t.string "magical_effects"
    t.decimal "unit_weight", precision: 5, scale: 2, null: false
    t.boolean "dragon_priest_mask", default: false
    t.boolean "quest_item", default: false
    t.boolean "unique_item", default: false
    t.boolean "enchantable", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_code"], name: "index_canonical_armors_on_item_code", unique: true
  end

  create_table "canonical_books", force: :cascade do |t|
    t.string "title", null: false
    t.string "title_variants", default: [], array: true
    t.string "item_code", null: false
    t.decimal "unit_weight", precision: 5, scale: 2, null: false
    t.string "book_type", null: false
    t.string "authors", default: [], array: true
    t.string "skill_name"
    t.boolean "purchasable", null: false
    t.boolean "unique_item", default: false, null: false
    t.boolean "rare_item", default: false, null: false
    t.boolean "solstheim_only", default: false, null: false
    t.boolean "quest_item", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_code"], name: "index_canonical_books_on_item_code", unique: true
  end

  create_table "canonical_clothing_items", force: :cascade do |t|
    t.string "name", null: false
    t.string "item_code", null: false
    t.string "body_slot", null: false
    t.string "magical_effects"
    t.decimal "unit_weight", precision: 5, scale: 2, null: false
    t.boolean "quest_item", default: false
    t.boolean "unique_item", default: false
    t.boolean "enchantable", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_code"], name: "index_canonical_clothing_items_on_item_code", unique: true
  end

  create_table "canonical_craftables_crafting_materials", force: :cascade do |t|
    t.bigint "material_id", null: false
    t.bigint "craftable_id", null: false
    t.string "craftable_type", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["material_id", "craftable_id", "craftable_type"], name: "index_can_craftables_crafting_materials_on_mat_id_and_craftable", unique: true
    t.index ["material_id"], name: "index_canonical_armors_smithing_mats_on_canonical_mat_id"
  end

  create_table "canonical_enchantables_enchantments", force: :cascade do |t|
    t.bigint "enchantment_id", null: false
    t.bigint "enchantable_id", null: false
    t.string "enchantable_type", null: false
    t.decimal "strength", precision: 5, scale: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["enchantment_id", "enchantable_id", "enchantable_type"], name: "index_enchantables_enchantments_on_enchmnt_id_enchble_id_type", unique: true
    t.index ["enchantment_id"], name: "index_canonical_enchantables_enchantments_on_enchantment_id"
  end

  create_table "canonical_ingredients", force: :cascade do |t|
    t.string "name", null: false
    t.string "item_code", null: false
    t.decimal "unit_weight", precision: 5, scale: 2, null: false
    t.boolean "quest_item", default: false
    t.boolean "unique_item", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_code"], name: "index_canonical_ingredients_on_item_code", unique: true
  end

  create_table "canonical_ingredients_alchemical_properties", force: :cascade do |t|
    t.bigint "alchemical_property_id", null: false
    t.bigint "ingredient_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "priority", null: false
    t.decimal "strength_modifier"
    t.decimal "duration_modifier"
    t.index ["alchemical_property_id", "ingredient_id"], name: "index_can_ingredients_alc_properties_on_property_and_ingr_ids", unique: true
    t.index ["alchemical_property_id"], name: "index_can_ingredients_alc_properties_on_alc_property_id"
    t.index ["ingredient_id"], name: "index_can_ingredients_alc_properties_on_can_ingredient_id"
    t.index ["priority", "ingredient_id"], name: "index_can_ingrs_alc_props_on_priority_and_ingr_id", unique: true
  end

  create_table "canonical_jewelry_items", force: :cascade do |t|
    t.string "name", null: false
    t.string "item_code", null: false
    t.string "jewelry_type", null: false
    t.string "magical_effects"
    t.decimal "unit_weight", precision: 5, scale: 2, null: false
    t.boolean "quest_item", default: false
    t.boolean "unique_item", default: false
    t.boolean "enchantable", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_code"], name: "index_canonical_jewelry_items_on_item_code", unique: true
  end

  create_table "canonical_materials", force: :cascade do |t|
    t.string "name", null: false
    t.string "item_code", null: false
    t.boolean "building_material", default: false
    t.boolean "smithing_material", default: false
    t.decimal "unit_weight", precision: 5, scale: 2, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_code"], name: "index_canonical_materials_on_item_code", unique: true
  end

  create_table "canonical_powerables_powers", force: :cascade do |t|
    t.bigint "power_id", null: false
    t.bigint "powerable_id", null: false
    t.string "powerable_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["power_id", "powerable_id", "powerable_type"], name: "index_powerables_powers_on_power_id_and_powerable", unique: true
    t.index ["power_id"], name: "index_canonical_powerables_powers_on_power_id"
  end

  create_table "canonical_properties", force: :cascade do |t|
    t.string "name", null: false
    t.string "hold", null: false
    t.string "city"
    t.boolean "alchemy_lab_available", default: true
    t.boolean "arcane_enchanter_available", default: false
    t.boolean "forge_available", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["city"], name: "index_canonical_properties_on_city", unique: true
    t.index ["hold"], name: "index_canonical_properties_on_hold", unique: true
    t.index ["name"], name: "index_canonical_properties_on_name", unique: true
  end

  create_table "canonical_recipes_ingredients", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "ingredient_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ingredient_id"], name: "index_canonical_recipes_ingredients_on_ingredient_id"
    t.index ["recipe_id", "ingredient_id"], name: "index_can_books_ingredients_on_recipe_and_ingredient", unique: true
    t.index ["recipe_id"], name: "index_canonical_recipes_ingredients_on_recipe_id"
  end

  create_table "canonical_staves", force: :cascade do |t|
    t.string "name", null: false
    t.string "item_code", null: false
    t.decimal "unit_weight", precision: 5, scale: 2, null: false
    t.integer "base_damage", null: false
    t.string "magical_effects"
    t.string "school"
    t.string "enemy"
    t.boolean "daedric", default: false, null: false
    t.boolean "unique_item", default: false, null: false
    t.boolean "quest_item", default: false, null: false
    t.boolean "leveled", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_code"], name: "index_canonical_staves_on_item_code", unique: true
  end

  create_table "canonical_staves_spells", force: :cascade do |t|
    t.bigint "spell_id", null: false
    t.bigint "staff_id", null: false
    t.integer "strength"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["spell_id", "staff_id"], name: "index_canonical_staves_spells_on_spell_id_and_staff_id", unique: true
    t.index ["spell_id"], name: "index_canonical_staves_spells_on_spell_id"
    t.index ["staff_id"], name: "index_canonical_staves_spells_on_staff_id"
  end

  create_table "canonical_temperables_tempering_materials", force: :cascade do |t|
    t.bigint "material_id", null: false
    t.bigint "temperable_id", null: false
    t.string "temperable_type", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["material_id", "temperable_id", "temperable_type"], name: "index_temperables_tempering_mats_on_mat_id_and_temperable", unique: true
    t.index ["material_id"], name: "index_canonical_armors_tempering_mats_on_canonical_material_id"
  end

  create_table "canonical_weapons", force: :cascade do |t|
    t.string "name", null: false
    t.string "item_code", null: false
    t.string "category", null: false
    t.string "weapon_type", null: false
    t.string "magical_effects"
    t.string "smithing_perks", default: [], array: true
    t.integer "base_damage", null: false
    t.decimal "unit_weight", precision: 5, scale: 2, null: false
    t.boolean "leveled", default: false
    t.boolean "enchantable", default: true
    t.boolean "quest_item", default: false
    t.boolean "unique_item", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_code"], name: "index_canonical_weapons_on_item_code", unique: true
  end

  create_table "enchantments", force: :cascade do |t|
    t.string "name", null: false
    t.string "enchantable_items", default: [], array: true
    t.string "strength_unit"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "school"
    t.index ["name"], name: "index_enchantments_on_name", unique: true
  end

  create_table "games", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "user_id"], name: "index_games_on_name_and_user_id", unique: true
    t.index ["user_id"], name: "index_games_on_user_id"
  end

  create_table "inventory_items", force: :cascade do |t|
    t.bigint "list_id", null: false
    t.string "description", null: false
    t.string "notes"
    t.integer "quantity", default: 1, null: false
    t.decimal "unit_weight", precision: 5, scale: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["description", "list_id"], name: "index_inventory_items_on_description_and_list_id", unique: true
    t.index ["list_id"], name: "index_inventory_items_on_list_id"
  end

  create_table "inventory_lists", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "aggregate_list_id"
    t.string "title", null: false
    t.boolean "aggregate", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "property_id"
    t.index ["aggregate_list_id"], name: "index_inventory_lists_on_aggregate_list_id"
    t.index ["game_id"], name: "index_inventory_lists_on_game_id"
    t.index ["property_id"], name: "index_inventory_lists_on_property_id"
    t.index ["title", "game_id"], name: "index_inventory_lists_on_title_and_game_id", unique: true
  end

  create_table "powers", force: :cascade do |t|
    t.string "name", null: false
    t.string "power_type", null: false
    t.string "source", null: false
    t.string "description", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_powers_on_name", unique: true
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "canonical_property_id", null: false
    t.string "name", null: false
    t.string "hold", null: false
    t.string "city"
    t.boolean "has_alchemy_lab", default: false
    t.boolean "has_arcane_enchanter", default: false
    t.boolean "has_forge", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["canonical_property_id"], name: "index_properties_on_canonical_property_id"
    t.index ["game_id", "canonical_property_id"], name: "index_properties_on_game_id_and_canonical_property_id", unique: true
    t.index ["game_id", "city"], name: "index_properties_on_game_id_and_city", unique: true
    t.index ["game_id", "hold"], name: "index_properties_on_game_id_and_hold", unique: true
    t.index ["game_id", "name"], name: "index_properties_on_game_id_and_name", unique: true
    t.index ["game_id"], name: "index_properties_on_game_id"
  end

  create_table "shopping_list_items", force: :cascade do |t|
    t.string "description", null: false
    t.string "notes"
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "list_id", null: false
    t.decimal "unit_weight", precision: 5, scale: 1
    t.index ["description", "list_id"], name: "index_shopping_list_items_on_description_and_list_id", unique: true
    t.index ["list_id"], name: "index_shopping_list_items_on_list_id"
  end

  create_table "shopping_lists", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "aggregate", default: false
    t.string "title", null: false
    t.bigint "game_id", null: false
    t.bigint "aggregate_list_id"
    t.bigint "property_id"
    t.index ["aggregate_list_id"], name: "index_shopping_lists_on_aggregate_list_id"
    t.index ["game_id"], name: "index_shopping_lists_on_game_id"
    t.index ["property_id"], name: "index_shopping_lists_on_property_id"
    t.index ["title", "game_id"], name: "index_shopping_lists_on_title_and_game_id", unique: true
  end

  create_table "spells", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.integer "strength"
    t.integer "base_duration"
    t.boolean "effects_cumulative", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "school", null: false
    t.string "level", null: false
    t.string "strength_unit"
    t.index ["name"], name: "index_spells_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "uid", null: false
    t.string "email", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "image_url"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "canonical_craftables_crafting_materials", "canonical_materials", column: "material_id"
  add_foreign_key "canonical_enchantables_enchantments", "enchantments"
  add_foreign_key "canonical_ingredients_alchemical_properties", "alchemical_properties"
  add_foreign_key "canonical_ingredients_alchemical_properties", "canonical_ingredients", column: "ingredient_id"
  add_foreign_key "canonical_powerables_powers", "powers"
  add_foreign_key "canonical_recipes_ingredients", "canonical_books", column: "recipe_id"
  add_foreign_key "canonical_recipes_ingredients", "canonical_ingredients", column: "ingredient_id"
  add_foreign_key "canonical_staves_spells", "canonical_staves", column: "staff_id"
  add_foreign_key "canonical_staves_spells", "spells"
  add_foreign_key "canonical_temperables_tempering_materials", "canonical_materials", column: "material_id"
  add_foreign_key "games", "users"
  add_foreign_key "inventory_items", "inventory_lists", column: "list_id"
  add_foreign_key "inventory_lists", "games"
  add_foreign_key "inventory_lists", "inventory_lists", column: "aggregate_list_id"
  add_foreign_key "inventory_lists", "properties"
  add_foreign_key "properties", "canonical_properties"
  add_foreign_key "properties", "games"
  add_foreign_key "shopping_list_items", "shopping_lists", column: "list_id"
  add_foreign_key "shopping_lists", "games"
  add_foreign_key "shopping_lists", "properties"
  add_foreign_key "shopping_lists", "shopping_lists", column: "aggregate_list_id"
end
