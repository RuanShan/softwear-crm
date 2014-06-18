require 'spec_helper'

describe Search::Filter, search_spec: true do
  it { should belong_to :model }

  it { should have_db_column :filter_type }
  it { should have_db_column :filter_id }
end