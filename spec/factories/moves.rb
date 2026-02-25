FactoryBot.define do
  factory :move do
    association :game
    association :player
    move_type { 'move' }
    position_row { 1 }
    position_col { 4 }
    move_number { 1 }
  end
end
