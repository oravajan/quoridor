require 'rails_helper'

RSpec.describe Wall, type: :model do
  describe 'database persistence and boundary validations' do
    let!(:game) { create(:game, board_size: 9) }
    let!(:player) { create(:player, game: game) }

    it 'creates a valid wall in the database' do
      expect {
        create(:wall, game: game, player: player, orientation: 'horizontal', row: 4, col: 4)
      }.to change(Wall, :count).by(1)
    end

    it 'fails to save if orientation is invalid' do
      wall = build(:wall, game: game, player: player, orientation: 'diagonal', row: 4, col: 4)
      expect(wall.save).to be false
    end

    it 'fails to save if coordinates are negative' do
      wall = build(:wall, game: game, player: player, orientation: 'horizontal', row: -1, col: 4)
      expect(wall.save).to be false
    end

    context 'when placing a HORIZONTAL wall' do
      it 'allows placement at the maximum valid boundaries' do
        wall = build(:wall, game: game, player: player, orientation: 'horizontal', row: 8, col: 7)
        expect(wall.save).to be true
      end

      it 'fails to save if it extends beyond the right edge of the board' do
        wall = build(:wall, game: game, player: player, orientation: 'horizontal', row: 4, col: 8)
        expect(wall.save).to be false
      end
    end

    context 'when placing a VERTICAL wall' do
      it 'allows placement at the maximum valid boundaries' do
        wall = build(:wall, game: game, player: player, orientation: 'vertical', row: 7, col: 8)
        expect(wall.save).to be true
      end

      it 'fails to save if it extends beyond the bottom edge of the board' do
        wall = build(:wall, game: game, player: player, orientation: 'vertical', row: 8, col: 4)
        expect(wall.save).to be false
      end
    end
  end
end
