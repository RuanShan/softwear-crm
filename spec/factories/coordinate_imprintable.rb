FactoryGirl.define do
  factory :blank_coordinate_imprintable, class: CoordinateImprintable do
    factory :coordinate_imprintable do
      imprintable { |i| i.association(:valid_imprintable) }
      coordinate { |c| c.association(:valid_imprintable) }
    end
  end
end
