require 'spec_helper'

describe LineItem, line_item_spec: true do
  context 'when imprintable_variant_id is nil' do
  	before(:each) { allow(subject).to receive(:imprintable_variant_id).and_return nil }

  	it { should_not validate_presence_of :imprintable_variant }
  	it { should validate_presence_of :description }
  	it { should validate_presence_of :name }

  	it 'description should return the description stored in the database' do
  		expect(subject.description).to eq subject.read_attribute :description
  	end
  end
  context 'when imprintable_variant_id is not nil' do
  	let!(:subject) { create :imprintable_line_item }
  	before(:each) { subject.imprintable_variant = create(:valid_imprintable_variant) }

    it 'should validate the existance of imprintable_variant' do
      subject.imprintable_variant_id = 99
      subject.save
      expect(subject.errors[:imprintable_variant]).to include("Imprintable Variant does not exist")
    end
  	it { should_not validate_presence_of :description }
  	it { should_not validate_presence_of :name }

  	it 'description should return the description of its imprintable_variant' do
  		expect(subject.description).to eq subject.imprintable_variant.imprintable.style.description
  	end
  end

  it '#price returns quantity times unit price' do
    line_item = create :non_imprintable_line_item
    expect(line_item.price).to eq line_item.unit_price * line_item.quantity
  end

  context '#<=>' do
    context 'on standard line items' do
      ['a', 'b', 'c'].each_with_index do |v,i|
        let!("line_item_#{i}".to_sym) do
          create :non_imprintable_line_item, name: "line_item_#{v}"
        end
      end

      it 'should sort them alphabetically' do
        expect([line_item_1, line_item_3, line_item_2].sort)
        .to eq [line_item_1, line_item_2, line_item_3]
      end
    end
    context 'on imprintable line items' do
      let!(:line_item_1) { create :imprintable_line_item }
    end
  end
end