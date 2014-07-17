FactoryGirl.define do
  factory :valid_imprintable_variant, class: ImprintableVariant do
    before(:create) do |variant|
      color = FactoryGirl.create(:valid_color)
      size = FactoryGirl.create(:valid_size)
      imprintable = FactoryGirl.create(:valid_imprintable)
      variant.imprintable = imprintable
      variant.color = color
      variant.size = size
      variant.color_id = color.id
      variant.size_id = size.id
      variant.imprintable_id = imprintable.id
    end
  end

  factory :associated_imprintable_variant, class: ImprintableVariant do
    color { |c| c.association(:valid_color) }
    size { |s| s.association(:valid_size) }
    imprintable { |i| i.association(:valid_imprintable) }
  end
end
