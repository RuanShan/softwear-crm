require 'spec_helper'

describe Search::Field, search_spec: true do
  it { should have_db_column :name }
  # No type field because the type is going to be text
  # it { should have_db_column :type }

  it { should belong_to :model }
  it { should have_and_belong_to :query }
end
