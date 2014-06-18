require 'spec_helper'

describe Search::Fulltext, search_spec: true do
  it { should have_db_column :boost }
  it { should belong_to :query }
  it { should belong_to :field }
end