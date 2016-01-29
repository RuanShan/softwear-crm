FactoryGirl.define do
  factory :admin_proof do
    sequence(:name) { |n| "Job ##{n}" }
    description "whatever"

    file_url Rails.root.join "spec/fixtures/images/macho.png"
    thumbnail_url Rails.root.join "spec/fixtures/images/macho.png"
  end
end
