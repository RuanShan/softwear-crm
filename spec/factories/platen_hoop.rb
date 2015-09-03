FactoryGirl.define do
  factory :platen_hoop, class: PlatenHoop do
    sequence(:name) { |n| ["Platen #{n}", "Hoop #{n}"][Random.rand(2)] }
    max_width { Random.rand(12) }
    max_height { Random.rand(12) }
  end
end
