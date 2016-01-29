FactoryGirl.define do
  factory :fba_imprint_template do
    print_location { |p| p.association(:valid_print_location) }
    description "it's here"
  end

  factory :fba_job_template do
    sequence(:name) { |n| "FBA JT #{n}" }
    mockup { |m| m.association(:valid_asset, file: File.open("#{Rails.root}/spec/fixtures/images/test-mockup.png")) }

    factory :fba_job_template_with_imprint do
      before(:create) do |fjt|
        fjt.fba_imprint_templates << build(:fba_imprint_template)
      end
    end
  end
end
