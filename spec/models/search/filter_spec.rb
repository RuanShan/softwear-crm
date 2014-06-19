require 'spec_helper'

describe Search::Filter, search_spec: true do
  it { should belong_to :query }
  it { should have_db_column :model }
  it { should have_db_column :field }
  
  # Might not need this; might be able to define a filter table registry from the descendant stuff
  # and if models are eager loaded, that would work nicely
  #
  # and in case you're too tired to get it,
  # the specific filters would have a filter_key
  # and somewhere it would validate that 
  # each filter only has one filter type
  # pointing to it
  it { should have_db_column :filter_type }
  it { should have_db_column :filter_id }

  context 'descendant classes' do
    # SET SUBJECT TO DUMMY DESCENDANT

    it 'should raise an error if the proper functions are not overriden when called', pending: true do
      [:insert, :proper, :functions, :here].each do |meth|
        expect(subject.methods).to include meth
        expect{subject.send(meth)}.to raise_error
      end
    end

    it 'should have access to the field name and model'

    it 'should be destroyed when the underlying Filter is destroyed'
  end

end