require 'spec_helper'
include LineItemHelpers

describe LineItem, line_item_spec: true do
  it { should validate_presence_of :unit_price }
  it { should validate_presence_of :quantity }

  context 'when imprintable_variant_id is nil' do
  	before(:each) { allow(subject).to receive(:imprintable_variant_id).and_return nil }

  	it { should_not validate_presence_of :imprintable_variant }
  	it { should validate_presence_of :description }
  	it { should validate_presence_of :name }

    it 'name should return the name stored in the database' do
      expect(subject.name).to eq subject.read_attribute :name
    end
    it 'description should return the description stored in the database' do
      expect(subject.description).to eq subject.read_attribute :description
    end
  end
  context 'when imprintable_variant_id is not nil' do
  	let!(:subject) { create :imprintable_line_item }
  	before(:each) { subject.imprintable_variant = create(:associated_imprintable_variant) }

    it 'should validate the existance of imprintable_variant' do
      subject.imprintable_variant_id = 99
      subject.save
      expect(subject.errors[:imprintable_variant]).to include("does not exist")
    end
  	it { should_not validate_presence_of :description }
  	it { should_not validate_presence_of :name }

    it 'name should return the name of its imprintable_variant' do
      expect(subject.name).to eq subject.imprintable_variant.name
    end
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
      ['c', 'a', 'b'].each do |v|
        let!("line_item_#{v}".to_sym) do
          create :non_imprintable_line_item, name: "line_item_#{v}"
        end
      end

      it 'should sort them alphabetically' do
        expect([line_item_a, line_item_c, line_item_b].sort)
        .to eq [line_item_a, line_item_b, line_item_c]
      end
    end
    context 'on imprintable line items' do
      let!(:job) { create(:job) }
      let!(:white) { create(:valid_color, name: 'white') }
      let!(:shirt) { create(:associated_imprintable) }
      make_variants :white, :shirt, [:M, :S, :L]

      before(:each) do
        size_s.sort_order = 1
        size_m.sort_order = 2
        size_l.sort_order = 3
        [size_s, size_m, size_l].each do |s|
          s.save
        end
      end

      it 'should sort them by the size sort order' do
        expect([white_shirt_m_item, white_shirt_l_item, white_shirt_s_item].sort)
        .to eq [white_shirt_s_item, white_shirt_m_item, white_shirt_l_item]
      end
    end
  end
end