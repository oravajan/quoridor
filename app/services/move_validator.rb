# Validates whether a pawn move is legal according to Quoridor rules.
#
# Handles:
# - Basic moves (one step in any cardinal direction)
# - Wall collision detection
# - Jumping over an opponent
# - Diagonal jumps when a direct jump is blocked by a wall
#
# Usage:
#   result = MoveValidator.call(game: game, player: player, to_row: 4, to_col: 3)
#   result.valid?   => true / false
#   result.errors   => ['Move is blocked by a wall']
class MoveValidator
  Result = Struct.new(:valid?, :errors)

  def self.call(game:, player:, to_row:, to_col:)
    new(game: game, player: player, to_row: to_row, to_col: to_col).call
  end

  def initialize(game:, player:, to_row:, to_col:)
    @game = game
    @player = player
    @from_row = player.position_row
    @from_col = player.position_col
    @to_row = to_row
    @to_col = to_col
    @walls = game.walls
    @opponent = game.players.find { |p| p.id != player.id }
  end

  def call
    errors = validate
    Result.new(errors.empty?, errors)
  end

  private

  def validate
    errors = []
    errors << "Target position is outside the board" unless within_board?(@to_row, @to_col)
    errors << "Invalid move" unless valid_move?
    errors
  end

  # Checks if the move is a valid basic step or a valid jump
  def valid_move?
    row_diff = (@to_row - @from_row).abs
    col_diff = (@to_col - @from_col).abs

    # Must move in one direction only or jump opponent
    return false unless (row_diff == 1 && col_diff == 0) || (row_diff == 0 && col_diff == 1) ||
                        valid_jump?

    # Basic move – check walls and opponent
    if row_diff + col_diff == 1
      return false if wall_between?(@from_row, @from_col, @to_row, @to_col)
      return false if opponent_at?(@to_row, @to_col)
    end

    true
  end

  # Checks if the move is a valid jump over the opponent
  def valid_jump?
    row_diff = @to_row - @from_row
    col_diff = @to_col - @from_col

    # Direct jump
    if (row_diff.abs == 2 && col_diff == 0) || (row_diff == 0 && col_diff.abs == 2)
      opponent_row = @from_row + row_diff / 2
      opponent_col = @from_col + col_diff / 2
      return false unless opponent_at?(opponent_row, opponent_col)
      return false if wall_between?(@from_row, @from_col, opponent_row, opponent_col)
      return !wall_between?(opponent_row, opponent_col, @to_row, @to_col)
    end

    # Diagonal jump, direct jump must be blocked
    if row_diff.abs == 1 && col_diff.abs == 1
      opponent_same_row = opponent_at?(@from_row, @from_col + col_diff)
      opponent_same_col = opponent_at?(@from_row + row_diff, @from_col)

      if opponent_same_row
        behind_row = @opponent.position_row
        behind_col = @opponent.position_col + col_diff
      elsif opponent_same_col
        behind_row = @opponent.position_row + row_diff
        behind_col = @opponent.position_col
      else
        return false
      end

      return false if wall_between?(@from_row, @from_col, @opponent.position_row, @opponent.position_col)
      # Check if direct jump is not valid
      return false unless wall_between?(@opponent.position_row, @opponent.position_col, behind_row, behind_col) ||
                          !within_board?(behind_row, behind_col)
      return !wall_between?(@opponent.position_row, @opponent.position_col, @to_row, @to_col)
    end

    false
  end

  # Checks if there is a wall between two adjacent cells
  def wall_between?(from_row, from_col, to_row, to_col)
    if to_row == from_row + 1 # moving down
      @walls.any? { |w| w.orientation == "horizontal" &&
        w.row == from_row &&
        (w.col == from_col || w.col == from_col - 1) }
    elsif to_row == from_row - 1 # moving up
      @walls.any? { |w| w.orientation == "horizontal" &&
        w.row == to_row &&
        (w.col == from_col || w.col == from_col - 1) }
    elsif to_col == from_col + 1 # moving right
      @walls.any? { |w| w.orientation == "vertical" &&
        w.col == from_col &&
        (w.row == from_row || w.row == from_row - 1) }
    elsif to_col == from_col - 1 # moving left
      @walls.any? { |w| w.orientation == "vertical" &&
        w.col == to_col &&
        (w.row == from_row || w.row == from_row - 1) }
    else
      false
    end
  end

  def opponent_at?(row, col)
    @opponent.position_row == row && @opponent.position_col == col
  end

  def within_board?(row, col)
    row.between?(0, @game.board_size - 1) && col.between?(0, @game.board_size - 1)
  end
end
