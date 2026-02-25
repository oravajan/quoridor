require 'rails_helper'

RSpec.describe Move, type: :model do
  describe 'database persistence and conditional validations' do
    let!(:game) { create(:game) }
    let!(:player) { create(:player, game: game) }

    context 'when move_type is "move" (moving the pawn)' do
      it 'creates a valid move in the database' do
        expect {
          create(:move, game: game, player: player, move_type: 'move', position_row: 1, position_col: 4, move_number: 1)
        }.to change(Move, :count).by(1)
      end

      it 'fails to save if position_row is missing' do
        move = build(:move, game: game, player: player, move_type: 'move', position_row: nil, position_col: 4, move_number: 1)
        expect(move.save).to be false
      end

      it 'fails to save if position_col is missing' do
        move = build(:move, game: game, player: player, move_type: 'move', position_row: 1, position_col: nil, move_number: 1)
        expect(move.save).to be false
      end
    end

    context 'when move_type is "wall" (placing a wall)' do
      let!(:wall) { create(:wall, game: game, player: player, orientation: 'horizontal', row: 4, col: 4) }

      it 'creates a valid wall placement in the database' do
        expect {
          create(:move, game: game, player: player, move_type: 'wall', wall: wall, move_number: 2, position_row: nil, position_col: nil)
        }.to change(Move, :count).by(1)
      end

      it 'fails to save if the wall reference is missing' do
        move = build(:move, game: game, player: player, move_type: 'wall', wall: nil, move_number: 2)
        expect(move.save).to be false
      end
    end

    context 'general validations' do
      it 'fails with an invalid move_type' do
        move = build(:move, game: game, player: player, move_type: 'jump', move_number: 1)
        expect(move.save).to be false
      end

      it 'fails if move_number is zero or negative' do
        move = build(:move, game: game, player: player, move_type: 'move', position_row: 1, position_col: 4, move_number: 0)
        expect(move.save).to be false
      end
    end
  end
end
