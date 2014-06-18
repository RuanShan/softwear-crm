require 'spec_helper'

describe Search::Filter, search_spec: true do
  it { should belong_to :model }
  it { should have_db_column :field_name } # String column

  context 'descendant classes' do
    it 'should raise an error if the proper functions are not overriden when called'

    it 'should have access to the field name and model'

    it 'should be destroyed when the underlying Filter is destroyed'
  end

  it { should have_db_column :filter_type }
  it { should have_db_column :filter_id }
end