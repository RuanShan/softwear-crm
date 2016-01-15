FactoryGirl.define do
  factory :fba_sku do
    sequence(:sku) { |n| "0-prodo-#{n}-ct-129219012" }
    imprintable_variant { |v| v.association(:associated_imprintable_variant) }
    fba_job_template { |j| j.association(:fba_job_template_with_imprint) }
  end

  factory :fba_product do
    sequence(:name) { |n| "Some Product #{n}" }
    sequence(:sku) { |n| "prodo-#{n}-ct" }
  end
end
