require 'rails_helper'

RSpec.describe Player, type: :model do
  describe 'database persistence and validations' do
    let!(:game) { create(:game, board_size: 9, initial_walls: 10) }

    it 'creates a valid player in the database' do
      expect {
        create(:player, game: game, player_number: 1, position_row: 0, position_col: 4, walls_remaining: 10)
      }.to change(Player, :count).by(1)
    end

    it 'fails to create a player with a position outside the board' do
      player = build(:player, game: game, position_row: 9, position_col: 4)
      expect(player).not_to be_valid
      expect(player.save).to be false
    end

    it 'fails to update an existing player to an invalid position' do
      player = create(:player, game: game, position_row: 0, position_col: 4)
      expect(player.update(position_col: -1)).to be false
      expect(player.reload.position_col).to eq(4)
    end

    it 'fails when a player has more walls than the game allows' do
      player = build(:player, game: game, walls_remaining: 11)
      expect(player).not_to be_valid
      expect(player.save).to be false
    end
  end
end
