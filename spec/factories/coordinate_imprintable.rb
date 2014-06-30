FactoryGirl.define do
  factory :coordinate_imprintable, class: CoordinateImprintable do
    imprintable { |i| i.association(:valid_imprintable) }
    coordinate { |c| c.association(:valid_imprintable) }
  end
end
