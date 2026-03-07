require 'rails_helper'

RSpec.describe GameCreator do
  describe '.call' do
    subject(:result) { GameCreator.call(board_size: 9, initial_walls: 10) }

    context 'when params are valid' do
      it 'returns a successful result' do
        expect(result).to be_success
      end

      it 'creates a game' do
        expect { result }.to change(Game, :count).by(1)
      end

      it 'creates two players' do
        expect { result }.to change(Player, :count).by(2)
      end

      it 'sets correct board size and initial walls on the game' do
        expect(result.game.board_size).to eq(9)
        expect(result.game.initial_walls).to eq(10)
      end

      it 'places player 1 at the top center' do
        player1 = result.game.players.find_by(player_number: 1)
        expect(player1.position_row).to eq(0)
        expect(player1.position_col).to eq(4)
      end

      it 'places player 2 at the bottom center' do
        player2 = result.game.players.find_by(player_number: 2)
        expect(player2.position_row).to eq(8)
        expect(player2.position_col).to eq(4)
      end

      it 'sets walls_remaining from initial_walls for both players' do
        expect(result.game.players).to all(have_attributes(walls_remaining: 10))
      end

      context 'with custom board size' do
        subject(:result) { GameCreator.call(board_size: 11, initial_walls: 8) }

        it 'places players at correct center positions' do
          player1 = result.game.players.find_by(player_number: 1)
          player2 = result.game.players.find_by(player_number: 2)
          expect(player1.position_col).to eq(5)
          expect(player1.position_row).to eq(0)
          expect(player2.position_col).to eq(5)
          expect(player2.position_row).to eq(10)
        end
      end
    end

    context 'when board_size is invalid' do
      subject(:result) { GameCreator.call(board_size: 0, initial_walls: 10) }

      it 'returns a failed result' do
        expect(result).not_to be_success
      end

      it 'does not create a game' do
        expect { result }.not_to change(Game, :count)
      end

      it 'does not create any players' do
        expect { result }.not_to change(Player, :count)
      end

      it 'returns errors' do
        expect(result.errors).not_to be_empty
      end
    end

    context 'when initial_walls is invalid' do
      subject(:result) { GameCreator.call(board_size: 9, initial_walls: 0) }

      it 'returns a failed result' do
        expect(result).not_to be_success
      end

      it 'does not create a game' do
        expect { result }.not_to change(Game, :count)
      end
    end
  end
end
