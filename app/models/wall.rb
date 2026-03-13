class Wall < ApplicationRecord
  belongs_to :game
  belongs_to :player

  validates :orientation, inclusion: { in: %w[horizontal vertical] }
  validates :row, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: ->(wall) { wall.game.board_size - 2 }
  }
  validates :col, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: ->(wall) { wall.game.board_size - 2 }
  }
end
