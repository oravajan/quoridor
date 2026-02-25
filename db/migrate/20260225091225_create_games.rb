class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :status, null: false, default: 'in_progress'
      t.integer :current_player_number, null: false, default: 1
      t.integer :winner_id
      t.integer :board_size, null: false
      t.integer :initial_walls, null: false
      t.timestamps
    end
  end
end
