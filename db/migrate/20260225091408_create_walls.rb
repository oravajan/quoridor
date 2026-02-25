class CreateWalls < ActiveRecord::Migration[8.1]
  def change
    create_table :walls do |t|
      t.references :game, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.integer :row, null: false
      t.integer :col, null: false
      t.string :orientation, null: false
      t.datetime :created_at, null: false
    end
  end
end
