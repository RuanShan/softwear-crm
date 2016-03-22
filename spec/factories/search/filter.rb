FactoryGirl.define do
  factory :filter, class: Search::Filter do
    [:number, :boolean, :string, :reference, :date, :phrase].each do |type|
      factory "#{type}_filter" do
        filter_type { |t| t.association "filter_type_#{type}" }
      end
    end
    factory :filter_group do
      filter_type { |t| t.association :filter_type_group }
    end
  end
  

  factory :filter_type_number, class: Search::NumberFilter do
    field 'commission_amount'
    comparator '='
    negate false
    value 10
  end

  factory :filter_type_boolean, class: Search::BooleanFilter do
    field '?'
    negate false
    value true
  end

  factory :filter_type_string, class: Search::StringFilter do
    field 'firstname'
    negate false
    value 'Test'
  end

  factory :filter_type_reference, class: Search::ReferenceFilter do
    field 'salesperson'
    negate false
    value { |v| v.associations :user }
  end

  factory :filter_type_date, class: Search::DateFilter do
    field 'created_at'
    negate false
    comparator '>'
    value 1.day.ago
  end

  factory :filter_type_phrase, class: Search::PhraseFilter do
    field 'whocares'
    value '"test"'
  end

  factory :filter_type_sort, class: Search::SortFilter do
    field 'created_at'
    value 'desc'
  end

  factory :filter_type_group, class: Search::FilterGroup do
    all true
  end
end
