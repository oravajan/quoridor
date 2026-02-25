FactoryBot.define do
  factory :wall do
    association :game
    association :player
    row { 3 }
    col { 3 }
    orientation { 'horizontal' }
  end
end
