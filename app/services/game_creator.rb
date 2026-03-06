class GameCreator
  Result = Struct.new(:success?, :game, :errors)

  def self.call(params)
    new(params).call
  end

  def initialize(params)
    @board_size = params[:board_size]
    @initial_walls = params[:initial_walls]
  end

  def call
    game = Game.new(board_size: @board_size, initial_walls: @initial_walls)

    unless game.valid?
      return Result.new(false, nil, game.errors)
    end

    Game.transaction do
      game.save!
      create_player(game, player_number: 1, row: 0, col: @board_size / 2)
      create_player(game, player_number: 2, row: @board_size - 1, col: @board_size / 2)
    end

    Result.new(true, game, [])
  rescue ActiveRecord::RecordInvalid => e
    Result.new(false, nil, e.record.errors)
  end

  private

  def create_player(game, player_number:, row:, col:)
    game.players.create!(
      player_number: player_number,
      position_row: row,
      position_col: col,
      walls_remaining: @initial_walls
    )
  end
end
