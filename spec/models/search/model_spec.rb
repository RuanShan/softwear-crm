require 'spec_helper'

describe Search::Model, search_spec: true do
  it { should have_db_column :name }

  it { should have_many :filters }
  it { should have_many :fields }
end