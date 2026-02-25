FactoryBot.define do
  factory :game do
    status { 'in_progress' }
    current_player_number { 1 }
    board_size { 9 }
    initial_walls { 10 }
  end
end
