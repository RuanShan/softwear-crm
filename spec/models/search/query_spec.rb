require 'spec_helper'

describe Search::Query, search_spec: true do
  it { should belong_to :user }
  it { should have_db_column :name }

  it { should have_many :fields }
  it { should have_many :filters }
end