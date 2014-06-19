require 'spec_helper'

describe Search::Filter, search_spec: true do
  it { should belong_to :filter_group }
  it { should have_db_column :model }
  it { should have_db_column :field }

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