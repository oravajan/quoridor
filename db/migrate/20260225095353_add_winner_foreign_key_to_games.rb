class AddWinnerForeignKeyToGames < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :games, :players, column: :winner_id
  end
end
