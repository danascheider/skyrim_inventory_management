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

ActiveRecord::Schema.define(version: 2021_08_28_040417) do

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
    t.index ["aggregate_list_id"], name: "index_inventory_lists_on_aggregate_list_id"
    t.index ["game_id"], name: "index_inventory_lists_on_game_id"
    t.index ["title", "game_id"], name: "index_inventory_lists_on_title_and_game_id", unique: true
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
    t.index ["aggregate_list_id"], name: "index_shopping_lists_on_aggregate_list_id"
    t.index ["game_id"], name: "index_shopping_lists_on_game_id"
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

  add_foreign_key "games", "users"
  add_foreign_key "inventory_items", "inventory_lists", column: "list_id"
  add_foreign_key "inventory_lists", "games"
  add_foreign_key "inventory_lists", "inventory_lists", column: "aggregate_list_id"
  add_foreign_key "shopping_list_items", "shopping_lists", column: "list_id"
  add_foreign_key "shopping_lists", "games"
  add_foreign_key "shopping_lists", "shopping_lists", column: "aggregate_list_id"
end
