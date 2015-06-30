FactoryGirl.define do
  factory :imprintable_photo do
    color { |c| c.association(:valid_color) }
    asset { |a| a.association(:valid_asset) }
    imprintable { |i| i.association(:valid_imprintable) }
    default false

    factory :default_imprintable_photo do
      default true
    end
  end
end
