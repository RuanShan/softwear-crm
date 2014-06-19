require 'spec_helper'

describe Search::QueryField, search_spec: true do
  it { should belong_to :query_model }
  # it { should have_one :query, through: :query_model }
  it { should have_db_column :name }
end
