class Game < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :walls, dependent: :destroy
  has_many :moves, dependent: :destroy
  belongs_to :winner, class_name: "Player", optional: true

  validates :status, inclusion: { in: %w[in_progress finished] }
  validates :current_player_number, inclusion: { in: [ 1, 2 ] }
  validates :board_size, numericality: { greater_than: 0 }
  validates :initial_walls, numericality: { greater_than: 0 }
end
