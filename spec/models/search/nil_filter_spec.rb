require 'spec_helper'

describe Search::NilFilter, search_spec: true do
  it { expect(subject.class.ancestors).to include Search::FilterType }

  it { should have_db_column :field }
  it { should_not have_db_column :value }
  it { should have_db_column :not }
end