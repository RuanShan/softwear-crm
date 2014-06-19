require 'spec_helper'

describe Search::FilterGroup, search_spec: true do
  it { should be kind_of Search::FilterType }

  it { should have_many :filters, as: :filter_holder }

  it { should have_db_column :all }
end