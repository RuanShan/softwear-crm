require 'spec_helper'

describe Search::BooleanFilter, search_spec: true do
  it { should be kind_of Search::FilterType }

  it { should have_db_column :field }
  it { should have_db_column :value }
  it { should have_db_column :not }
end