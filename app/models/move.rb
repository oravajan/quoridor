class Move < ApplicationRecord
  belongs_to :game
  belongs_to :player
  belongs_to :wall, optional: true

  validates :move_type, inclusion: { in: %w[move wall] }
  validates :move_number, numericality: { greater_than: 0 }

  with_options if: -> { move_type == "move" } do
    validates :position_row, presence: true
    validates :position_col, presence: true
  end

  with_options if: -> { move_type == "wall" } do
    validates :wall, presence: true
  end
end
