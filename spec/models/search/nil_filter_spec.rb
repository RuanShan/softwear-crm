require 'spec_helper'

describe Search::NilFilter, search_spec: true do
  it { should be kind_of Search::FilterType }

  it { should have_db_column :field }
  it { should_not have_db_column :value }
  it { should have_db_column :not }
end