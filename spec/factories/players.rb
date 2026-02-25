FactoryBot.define do
  factory :player do
    association :game
    player_number { 1 }
    position_row { 0 }
    position_col { 4 }
    walls_remaining { 10 }
  end
end
