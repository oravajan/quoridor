require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'database lifecycle (CRUD)' do
    it 'creates a new game in the database' do
      expect {
        create(:game, status: 'in_progress')
      }.to change(Game, :count).by(1)
    end

    it 'updates the game status in the database' do
      game = create(:game, status: 'in_progress')
      game.update!(status: 'finished')
      expect(game.reload.status).to eq('finished')
    end

    it 'deletes the game from the database' do
      game = create(:game)
      expect {
        game.destroy
      }.to change(Game, :count).by(-1)
    end
  end

  describe 'cascading deletes' do
    it 'destroys associated players when the game is destroyed' do
      game = create(:game)
      create(:player, game: game)
      expect {
        game.destroy
      }.to change(Player, :count).by(-1)
    end
  end
end
