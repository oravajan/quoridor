require 'rails_helper'

RSpec.describe WallValidator do
  subject(:result) { WallValidator.call(game: game, player: player, row: row, col: col, orientation: orientation) }

  let(:game) { GameCreator.call(board_size: 9, initial_walls: 10).game }
  let(:player) { game.players.find_by(player_number: 1) }
  let(:opponent) { game.players.find_by(player_number: 2) }
  let(:row) { 3 }
  let(:col) { 3 }
  let(:orientation) { 'horizontal' }

  describe 'walls remaining' do
    context 'when player has walls remaining' do
      it { expect(result).to be_valid }
    end

    context 'when player has no walls remaining' do
      before { player.update!(walls_remaining: 0) }

      it { expect(result).not_to be_valid }
    end
  end

  describe 'board boundaries' do
    context 'when wall is outside the board' do
      context 'with negative position' do
        let(:row) { -1 }
        let(:col) { 5 }
        it { expect(result).not_to be_valid }
      end

      context 'with horizontal orientation' do
        let(:orientation) { 'horizontal' }

        context 'when row is at board edge' do
          let(:row) { 8 }
          let(:col) { 5 }
          it { expect(result).not_to be_valid }
        end

        context 'when col is at board edge' do
          let(:row) { 5 }
          let(:col) { 8 }
          it { expect(result).not_to be_valid }
        end
      end

      context 'with vertical orientation' do
        let(:orientation) { 'vertical' }

        context 'when row is at board edge' do
          let(:row) { 8 }
          let(:col) { 5 }
          it { expect(result).not_to be_valid }
        end

        context 'when col is at board edge' do
          let(:row) { 5 }
          let(:col) { 8 }
          it { expect(result).not_to be_valid }
        end
      end
    end

    context 'when wall is at the maximum valid position' do
      context 'with horizontal orientation' do
        let(:orientation) { 'horizontal' }

        context 'top left corner' do
          let(:row) { 0 }
          let(:col) { 0 }
          it { expect(result).to be_valid }
        end

        context 'top right corner' do
          let(:row) { 0 }
          let(:col) { 7 }
          it { expect(result).to be_valid }
        end

        context 'bottom right corner' do
          let(:row) { 7 }
          let(:col) { 7 }
          it { expect(result).to be_valid }
        end
      end

      context 'with vertical orientation' do
        let(:orientation) { 'vertical' }

        context 'top left corner' do
          let(:row) { 0 }
          let(:col) { 0 }
          it { expect(result).to be_valid }
        end

        context 'top right corner' do
          let(:row) { 0 }
          let(:col) { 7 }
          it { expect(result).to be_valid }
        end

        context 'bottom right corner' do
          let(:row) { 7 }
          let(:col) { 7 }
          it { expect(result).to be_valid }
        end
      end
    end
  end

  describe 'wall overlapping' do
    context 'when a horizontal wall overlaps with existing horizontal wall' do
      before { Wall.create!(game: game, player: opponent, row: 3, col: 3, orientation: 'horizontal') }

      it { expect(result).not_to be_valid }
    end

    context 'when a horizontal wall partially overlaps with existing horizontal wall' do
      before { Wall.create!(game: game, player: opponent, row: 3, col: 4, orientation: 'horizontal') }

      it { expect(result).not_to be_valid }
    end

    context 'when a vertical wall overlaps with existing vertical wall' do
      let(:orientation) { 'vertical' }
      before { Wall.create!(game: game, player: opponent, row: 3, col: 3, orientation: 'vertical') }

      it { expect(result).not_to be_valid }
    end

    context 'when a vertical wall partially overlaps with existing vertical wall' do
      let(:orientation) { 'vertical' }
      before { Wall.create!(game: game, player: opponent, row: 4, col: 3, orientation: 'vertical') }

      it { expect(result).not_to be_valid }
    end

    context 'when perpendicular walls cross each other' do
      let(:orientation) { 'vertical' }
      before { Wall.create!(game: game, player: opponent, row: 3, col: 3, orientation: 'horizontal') }

      it { expect(result).not_to be_valid }
    end

    context 'when walls are adjacent but do not overlap' do
      before { Wall.create!(game: game, player: opponent, row: 3, col: 5, orientation: 'horizontal') }

      it { expect(result).to be_valid }
    end

    context 'when perpendicular walls are adjacent but do not overlap' do
      before { Wall.create!(game: game, player: opponent, row: 2, col: 3, orientation: 'vertical') }

      it { expect(result).to be_valid }
    end
  end

  describe 'path blocking' do
    context 'when wall does not block any player' do
      it { expect(result).to be_valid }
    end

    context 'when wall completely blocks path for both players' do
      before do
        [ 0, 2, 4, 6 ].each { |c| Wall.create!(game: game, player: opponent, row: 4, col: c, orientation: 'horizontal') }
        Wall.create!(game: game, player: opponent, row: 3, col: 7, orientation: 'vertical')
        game.reload
      end

      let(:row) { 2 }
      let(:col) { 7 }

      it { expect(result).not_to be_valid }
    end

    context 'when wall completely blocks path for only one player' do
      before do
        Wall.create!(game: game, player: opponent, row: 7, col: 3, orientation: 'vertical')
        [ 3, 5 ].each { |c| Wall.create!(game: game, player: opponent, row: 6, col: c, orientation: 'horizontal') }
        game.reload
      end

      let(:row) { 6 }
      let(:col) { 7 }

      it { expect(result).not_to be_valid }
    end
  end
end
