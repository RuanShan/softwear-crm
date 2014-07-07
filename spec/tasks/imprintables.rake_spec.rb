require 'spec_helper'
require 'rake'

class DBStub
  def initialize(data_store)
    @data_store = data_store
  end

  def [](arg1, arg2)
    @data_store[arg1][arg2]
  end
end

def create_array_and_expect_results(ws)
  array = get_tags(ws, 0)
  resultant = ['Good', 'Tee Shirt', 'Short Sleeve', 'Crewneck',
               'Standard', 'Tees & Tanks', 'Least Expensive',
               'Regular Cotton', 'Least Expensive']
  expect(array).to eq resultant
end

describe 'imprintables namespace' do
  describe 'get_tags' do
    before do
      load File.expand_path('lib/tasks/imprintables.rake')
      Rake::Task.define_task(:environment)
    end

    context 'columns L through Q are contracted' do
      it 'should collect tags from the linked google doc' do
        ws = DBStub.new([[nil, 'Good','Gildan', '5000', 'Adult Heavy Cotton Short Sleeve Tee',
                               'S - 3XL', '$2.50', '$4.50', '$4.50', '--', '--', '--',
                               'SS or Heritage', 'y', 'Adult Unisex', 'Tee Shirt', 'Short Sleeve',
                               'Crewneck', '5.3', '100% Cotton', 'Standard', '63', '5000L, 5000B',
                               '', 'Std Crewneck Tee', 'Tees & Tanks', 'Least Expensive', 'Regular Cotton',
                               '', '', '', '', '', '', 'Least Expensive'], [], [], [nil, '', '', '', '', '', '', '', '', '', '', '', 'Main Supplier']])

        create_array_and_expect_results ws
      end
    end

    context 'columns M through Q are not contracted' do
      it 'should collect tags from the linked google doc' do
        ws = DBStub.new([[nil, 'Good','Gildan', '5000', 'Adult Heavy Cotton Short Sleeve Tee',
                          'S - 3XL', '$2.50', '$4.50', '$4.50', '--', '--', '--',
                          '$1.78', '$3.18', '$3.18', '--', '--', '--', 'SS or Heritage',
                          'y', 'Adult Unisex', 'Tee Shirt', 'Short Sleeve',
                          'Crewneck', '5.3', '100% Cotton', 'Standard', '63', '5000L, 5000B',
                          '', 'Std Crewneck Tee', 'Tees & Tanks', 'Least Expensive', 'Regular Cotton',
                          '', '', '', '', '', '', 'Least Expensive'], [], [], [nil, '', '', '', '', '', '', '', '', '', '', '', '']])

        create_array_and_expect_results ws
      end
    end
  end
end
