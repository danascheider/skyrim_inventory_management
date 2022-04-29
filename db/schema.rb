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

ActiveRecord::Schema.define(version: 2022_04_29_080952) do

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
    t.string "weight", null: false
    t.string "body_slot", null: false
    t.decimal "unit_weight", precision: 5, scale: 1
    t.boolean "dragon_priest_mask", default: false
    t.boolean "quest_item", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "canonical_armors_enchantments", force: :cascade do |t|
    t.bigint "canonical_armor_id", null: false
    t.bigint "enchantment_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["canonical_armor_id"], name: "index_canonical_armors_enchantments_on_canonical_armor_id"
    t.index ["enchantment_id"], name: "index_canonical_armors_enchantments_on_enchantment_id"
  end

  create_table "canonical_armors_smithing_materials", force: :cascade do |t|
    t.bigint "canonical_armor_id", null: false
    t.bigint "canonical_material_id", null: false
    t.integer "count", default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["canonical_armor_id"], name: "index_canonical_armors_smithing_mats_on_canonical_armor_id"
    t.index ["canonical_material_id"], name: "index_canonical_armors_smithing_mats_on_canonical_mat_id"
  end

  create_table "canonical_armors_tempering_materials", force: :cascade do |t|
    t.bigint "canonical_armor_id", null: false
    t.bigint "canonical_material_id", null: false
    t.integer "count", default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["canonical_armor_id"], name: "index_canonical_armors_tempering_mats_on_canonical_armor_id"
    t.index ["canonical_material_id"], name: "index_canonical_armors_tempering_mats_on_canonical_material_id"
  end

  create_table "canonical_clothing_items", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "unit_weight", default: "1.0"
    t.boolean "quest_item", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_canonical_clothing_items_on_name", unique: true
  end

  create_table "canonical_materials", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "building_material", default: false
    t.boolean "smithing_material", default: false
    t.decimal "unit_weight", precision: 5, scale: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_canonical_materials_on_name", unique: true
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

  add_foreign_key "canonical_armors_enchantments", "canonical_armors"
  add_foreign_key "canonical_armors_enchantments", "enchantments"
  add_foreign_key "canonical_armors_smithing_materials", "canonical_armors"
  add_foreign_key "canonical_armors_smithing_materials", "canonical_materials"
  add_foreign_key "canonical_armors_tempering_materials", "canonical_armors"
  add_foreign_key "canonical_armors_tempering_materials", "canonical_materials"
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
