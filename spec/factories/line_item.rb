FactoryGirl.define do
  factory :line_item do
    factory :non_imprintable_line_item do
      name 'Test Non-Imprintable'
      description 'Incredibly informative text'
    end

    factory :imprintable_line_item do
      imprintable_variant FactoryGirl.create(:valid_imprintable_variant)
    end
  # quantity maybe?
  end
end