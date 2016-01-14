FactoryGirl.define do
  factory :fba_job_template do
    sequence(:name) { |n| "FBA JT #{n}" }

    factory :fba_job_template_with_imprint do
      before(:create) do |fjt|
        fjt.imprints << build(:imprint_without_job)
      end
    end
  end
end
