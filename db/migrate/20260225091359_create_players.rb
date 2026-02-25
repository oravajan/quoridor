class CreatePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :players do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :player_number, null: false
      t.integer :position_row, null: false
      t.integer :position_col, null: false
      t.integer :walls_remaining, null: false
      t.timestamps
    end
  end
end
