class CreateMoves < ActiveRecord::Migration[8.1]
  def change
    create_table :moves do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.references :wall, foreign_key: true
      t.string :move_type, null: false
      t.integer :position_row
      t.integer :position_col
      t.integer :move_number, null: false
      t.datetime :created_at, null: false
    end
  end
end
