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

ActiveRecord::Schema[8.1].define(version: 2026_02_25_095353) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "games", force: :cascade do |t|
    t.integer "board_size", null: false
    t.datetime "created_at", null: false
    t.integer "current_player_number", default: 1, null: false
    t.integer "initial_walls", null: false
    t.string "status", default: "in_progress", null: false
    t.datetime "updated_at", null: false
    t.integer "winner_id"
  end

  create_table "moves", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "game_id", null: false
    t.integer "move_number", null: false
    t.string "move_type", null: false
    t.bigint "player_id", null: false
    t.integer "position_col"
    t.integer "position_row"
    t.bigint "wall_id"
    t.index ["game_id"], name: "index_moves_on_game_id"
    t.index ["player_id"], name: "index_moves_on_player_id"
    t.index ["wall_id"], name: "index_moves_on_wall_id"
  end

  create_table "players", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "game_id", null: false
    t.integer "player_number", null: false
    t.integer "position_col", null: false
    t.integer "position_row", null: false
    t.datetime "updated_at", null: false
    t.integer "walls_remaining", null: false
    t.index ["game_id"], name: "index_players_on_game_id"
  end

  create_table "walls", force: :cascade do |t|
    t.integer "col", null: false
    t.datetime "created_at", null: false
    t.bigint "game_id", null: false
    t.string "orientation", null: false
    t.bigint "player_id", null: false
    t.integer "row", null: false
    t.index ["game_id"], name: "index_walls_on_game_id"
    t.index ["player_id"], name: "index_walls_on_player_id"
  end

  add_foreign_key "games", "players", column: "winner_id"
  add_foreign_key "moves", "games"
  add_foreign_key "moves", "players"
  add_foreign_key "moves", "walls"
  add_foreign_key "players", "games"
  add_foreign_key "walls", "games"
  add_foreign_key "walls", "players"
end
