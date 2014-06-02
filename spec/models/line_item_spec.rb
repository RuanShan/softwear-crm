require 'spec_helper'

describe LineItem, line_item_spec: true do
  context 'when printable_variant_id is nil' do
  	before(:each) { allow(subject).to receive(:imprintable_variant_id).and_return nil }

  	it { should_not validate_presence_of :imprintable_variant }
  	it { should validate_presence_of :description }
  	it { should validate_presence_of :name }

  	it 'description should return the description stored in the database' do
  		expect(subject.description).to eq subject.read_attribute :description
  	end
  end
  context 'when printable_variant_id is not nil' do
  	let!(:subject) { create :imprintable_line_item }
  	# before(:each) { subject.imprintable_variant = create(:valid_imprintable_variant) }

  	it { should validate_presence_of :imprintable_variant }
  	it { should_not validate_presence_of :description }
  	it { should_not validate_presence_of :name }

  	it 'description should return the description of its imprintable_variant' do
  		puts '**********' + subject.imprintable_variant.imprintable.id.to_s
  		puts '^&*$^$^&$%&^%$&^$%^#$^%#$%@#$%@#$%@#$%#$@^&*$^$^&$%&^%$&^$%^#$^%#$%@#$%@#$%@#$%#$@^&*$^$^&$%&^%$&^$%^#$^%#$%@#$%@#$%@#$%#$@'
  		expect(subject.description).to eq subject.imprintable_variant.imprintable.description
  	end
  end

  it 'price method returns quantity times unit price' do
    line_item = create :line_item
    expect(line_item.price).to eq line_item.unit_price * line_item.quantity
  end


end