require 'rails_helper'

RSpec.describe MoveValidator do
  subject(:result) { MoveValidator.call(game: game, player: player, to_row: to_row, to_col: to_col) }

  let(:game) { GameCreator.call(board_size: 9, initial_walls: 10).game }
  let(:player) { game.players.find_by(player_number: 1) } # starts at (0, 4)
  let(:opponent) { game.players.find_by(player_number: 2) } # starts at (8, 4)

  describe 'basic moves' do
    context 'when moving one step down' do
      let(:to_row) { 1 }
      let(:to_col) { 4 }

      it { expect(result).to be_valid }
    end

    context 'when moving one step to the right' do
      let(:to_row) { 0 }
      let(:to_col) { 5 }

      it { expect(result).to be_valid }
    end

    context 'when moving one step to the left' do
      let(:to_row) { 0 }
      let(:to_col) { 3 }

      it { expect(result).to be_valid }
    end

    context 'when moving diagonally' do
      let(:to_row) { 1 }
      let(:to_col) { 5 }

      it { expect(result).not_to be_valid }
    end

    context 'when moving two steps' do
      let(:to_row) { 2 }
      let(:to_col) { 4 }

      it { expect(result).not_to be_valid }
    end

    context 'when moving outside the board' do
      let(:to_row) { -1 }
      let(:to_col) { 4 }

      it { expect(result).not_to be_valid }
    end

    context 'when moving to current position' do
      let(:to_row) { 0 }
      let(:to_col) { 4 }

      it { expect(result).not_to be_valid }
    end
  end

  describe 'wall blocking' do
    context 'when a horizontal wall blocks movement downward' do
      before do
        # wall at (row:0, col:3) blocks move from row 0 to row 1 for columns 3 and 4
        create(:wall, game: game, player: opponent, orientation: 'horizontal', row: 0, col: 3)
      end

      let(:to_row) { 1 }
      let(:to_col) { 4 }

      it { expect(result).not_to be_valid }
    end

    context 'when a horizontal wall blocks movement upward' do
      before do
        player.update!(position_row: 2, position_col: 4)
        create(:wall, game: game, player: opponent, orientation: 'horizontal', row: 1, col: 3)
      end

      let(:to_row) { 1 }
      let(:to_col) { 4 }

      it { expect(result).not_to be_valid }
    end

    context 'when a vertical wall blocks movement to the right' do
      before do
        create(:wall, game: game, player: opponent, orientation: 'vertical', row: 0, col: 4)
      end

      let(:to_row) { 0 }
      let(:to_col) { 5 }

      it { expect(result).not_to be_valid }
    end

    context 'when a vertical wall blocks movement to the left' do
      before do
        create(:wall, game: game, player: opponent, orientation: 'vertical', row: 0, col: 3)
      end

      let(:to_row) { 0 }
      let(:to_col) { 3 }

      it { expect(result).not_to be_valid }
    end

    context 'when a horizontal wall is adjacent but does not block the move' do
      before do
        create(:wall, game: game, player: opponent, orientation: 'horizontal', row: 0, col: 5)
      end

      let(:to_row) { 1 }
      let(:to_col) { 4 }

      it { expect(result).to be_valid }
    end

    context 'when a vertical wall is adjacent but does not block the move' do
      before do
        create(:wall, game: game, player: opponent, orientation: 'vertical', row: 0, col: 4)
      end

      let(:to_row) { 1 }
      let(:to_col) { 4 }

      it { expect(result).to be_valid }
    end
  end

  describe 'jumping over opponent' do
    before { opponent.update!(position_row: 1, position_col: 4) }

    context 'when jumping directly over opponent' do
      let(:to_row) { 2 }
      let(:to_col) { 4 }

      it { expect(result).to be_valid }
    end

    context 'when direct jump is blocked by a wall' do
      before do
        create(:wall, game: game, player: opponent, orientation: 'horizontal', row: 1, col: 3)
      end

      let(:to_row) { 2 }
      let(:to_col) { 4 }

      it { expect(result).not_to be_valid }
    end

    context 'when jumping diagonally because wall blocks direct jump' do
      before do
        create(:wall, game: game, player: opponent, orientation: 'horizontal', row: 1, col: 3)
      end

      context 'to the right' do
        let(:to_row) { 1 }
        let(:to_col) { 5 }

        it { expect(result).to be_valid }
      end

      context 'to the left' do
        let(:to_row) { 1 }
        let(:to_col) { 3 }

        it { expect(result).to be_valid }
      end
    end

    context 'when diagonal jump is blocked by a wall' do
      before do
        create(:wall, game: game, player: opponent, orientation: 'horizontal', row: 1, col: 3)
        create(:wall, game: game, player: opponent, orientation: 'vertical', row: 0, col: 4)
      end

      let(:to_row) { 1 }
      let(:to_col) { 5 }

      it { expect(result).not_to be_valid }
    end

    context 'when diagonal jump is not allowed because direct jump is free' do
      let(:to_row) { 1 }
      let(:to_col) { 5 }

      it { expect(result).not_to be_valid }
    end

    context 'when opponent is at the edge and direct jump is out of bounds' do
      before do
        player.update!(position_row: 0, position_col: 1)
        opponent.update!(position_row: 0, position_col: 0)
      end

      let(:to_row) { 1 }
      let(:to_col) { 0 }

      it { expect(result).to be_valid }
    end
  end

  describe 'moving onto opponent' do
    before { opponent.update!(position_row: 1, position_col: 4) }

    context 'when trying to move onto opponent position' do
      let(:to_row) { 1 }
      let(:to_col) { 4 }

      it { expect(result).not_to be_valid }
    end
  end
end
