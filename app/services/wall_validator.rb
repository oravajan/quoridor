# Validates whether placing a wall is legal according to Quoridor rules.
#
# Checks:
# - Player has walls remaining
# - Wall does not overlap with existing walls
# - Wall does not completely block either player's path to goal
#
# Usage:
#   result = WallValidator.call(game: game, player: player, row: 3, col: 4, orientation: "horizontal")
#   result.valid?  => true / false
#   result.errors  => ["Wall overlaps with existing wall"]
class WallValidator
  Result = Struct.new(:valid?, :errors)

  def self.call(game:, player:, row:, col:, orientation:)
    new(game: game, player: player, row: row, col: col, orientation: orientation).call
  end

  def initialize(game:, player:, row:, col:, orientation:)
    @game = game
    @player = player
    @row = row
    @col = col
    @orientation = orientation
    @walls = game.walls
    @players = game.players
  end

  def call
    errors = validate
    Result.new(errors.empty?, errors)
  end

  private

  def validate
    errors = []
    errors << "Wall is outside the board" unless within_board_boundaries?
    errors << "No walls remaining" unless walls_remaining?
    errors << "Wall overlaps with an existing wall" if overlaps?
    errors << "Wall would block a player's path" unless paths_open?
    errors
  end

  def walls_remaining?
    @player.walls_remaining > 0
  end

  # Checks if the new wall overlaps with any existing wall
  def overlaps?
    @walls.any? { |wall| overlaps_with?(wall) }
  end

  def overlaps_with?(wall)
    if @orientation == "horizontal" && wall.orientation == "horizontal"
      # Same row, columns overlap
      wall.row == @row && (wall.col - @col).abs <= 1
    elsif @orientation == "vertical" && wall.orientation == "vertical"
      # Same col, rows overlap
      wall.col == @col && (wall.row - @row).abs <= 1
    else
      # Perpendicular walls cross at the same cell
      @row == wall.row && @col == wall.col
    end
  end

  # Checks that both players still have a path to their goal after placing the wall
  def paths_open?
    simulated_walls = @walls.to_a + [ Wall.new(row: @row, col: @col, orientation: @orientation) ]

    @players.all? do |player|
      goal_row = player.player_number == 1 ? @game.board_size - 1 : 0
      bfs_path_exists?(
        start_row: player.position_row,
        start_col: player.position_col,
        goal_row: goal_row,
        walls: simulated_walls
      )
    end
  end

  # BFS to check if a path exists from start to goal row
  def bfs_path_exists?(start_row:, start_col:, goal_row:, walls:)
    visited = {}
    queue = [ [ start_row, start_col ] ]

    until queue.empty?
      row, col = queue.shift

      next if visited[[ row, col ]]
      visited[[ row, col ]] = true

      return true if row == goal_row

      neighbors(row, col, walls).each do |neighbor|
        queue << neighbor unless visited[neighbor]
      end
    end

    false
  end

  # Returns all reachable neighbors from a given cell
  def neighbors(row, col, walls)
    [
      [ row - 1, col ],
      [ row + 1, col ],
      [ row, col - 1 ],
      [ row, col + 1 ]
    ].select do |n_row, n_col|
      within_board?(n_row, n_col) &&
        !wall_between?(row, col, n_row, n_col, walls)
    end
  end

  def wall_between?(from_row, from_col, to_row, to_col, walls)
    if to_row == from_row + 1 # moving down
      walls.any? { |w| w.orientation == "horizontal" &&
        w.row == from_row &&
        (w.col == from_col || w.col == from_col - 1) }
    elsif to_row == from_row - 1 # moving up
      walls.any? { |w| w.orientation == "horizontal" &&
        w.row == to_row &&
        (w.col == from_col || w.col == from_col - 1) }
    elsif to_col == from_col + 1 # moving right
      walls.any? { |w| w.orientation == "vertical" &&
        w.col == from_col &&
        (w.row == from_row || w.row == from_row - 1) }
    elsif to_col == from_col - 1 # moving left
      walls.any? { |w| w.orientation == "vertical" &&
        w.col == to_col &&
        (w.row == from_row || w.row == from_row - 1) }
    else
      false
    end
  end

  def within_board_boundaries?
    @row.between?(0, @game.board_size - 2) &&
      @col.between?(0, @game.board_size - 2)
  end

  def within_board?(row, col)
    row.between?(0, @game.board_size - 1) && col.between?(0, @game.board_size - 1)
  end
end
