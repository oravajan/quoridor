class Player < ApplicationRecord
  belongs_to :game
  has_many :walls, dependent: :destroy
  has_many :moves, dependent: :destroy

  validates :player_number, inclusion: { in: [ 1, 2 ] }
  validates :position_row, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: ->(player) { player.game.board_size - 1 }
  }
  validates :position_col, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: ->(player) { player.game.board_size - 1 }
  }
  validates :walls_remaining, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: ->(player) { player.game.initial_walls }
  }
end
