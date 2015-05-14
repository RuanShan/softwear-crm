require 'spec_helper'
include LineItemHelpers

describe LineItem, line_item_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:imprintable_variant) }
    it { is_expected.to belong_to(:line_itemable) }
    # FIXME this doesn't work
    # it { is_expected.to have_one(:order).through(:job) }
  end

  describe 'Validations', now: true do
    describe 'quantity' do
      it { is_expected.to validate_presence_of :quantity }
      it { is_expected.to allow_value(5).for :quantity }
      it { is_expected.to_not allow_value(0).for :quantity }
      it { is_expected.to_not allow_value(-4).for :quantity }
    end

    context 'when imprintable_variant_id is nil' do
      before :each do
        allow(subject).to receive(:imprintable_variant_id).and_return nil
      end

      it { is_expected.to validate_presence_of :description }
      it { is_expected.to validate_presence_of :name }
      it { is_expected.to_not validate_presence_of :imprintable_variant }
      it { is_expected.to validate_presence_of :unit_price }

      it 'description returns the description stored in the database' do
        expect(subject.description).to eq subject[:description]
      end

      it 'name returns the name stored in the database' do
        expect(subject.name).to eq subject[:name]
      end
    end

    context 'when imprintable_variant_id is not nil' do
      let!(:subject) {}
      subject do
        create(
          :imprintable_line_item,
          imprintable_variant: create(:associated_imprintable_variant)
        )
      end

      it 'validates the existance of imprintable_variant' do
        subject.imprintable_variant_id = 99
        subject.save
        expect(subject.errors[:imprintable_variant])
          .to include('does not exist')
      end

      it { is_expected.to_not validate_presence_of :description }
      it { is_expected.to_not validate_presence_of :name }
      it { is_expected.to validate_uniqueness_of(:imprintable_variant_id)
             .scoped_to([:line_itemable_id, :line_itemable_type]) }
      it { is_expected.to validate_presence_of :decoration_price }
      it { is_expected.to validate_presence_of :imprintable_price }


      it 'description should return the imprintable_variant description' do
        expect(subject.description)
          .to eq subject.imprintable_variant.imprintable.style_description
      end
      it 'name should return the name of its imprintable_variant' do
        expect(subject.name).to eq subject.imprintable_variant.name
      end
    end

    describe 'unit_price' do
      it { is_expected.to allow_value(51.21).for :unit_price }
      it { is_expected.to allow_value(12.2).for :unit_price }
      it { is_expected.to allow_value(3).for :unit_price }
      it { is_expected.to_not allow_value(12.321).for :unit_price }
    end
  end

  describe '#<=>' do
    context 'on standard line items' do
      ['c', 'a', 'b'].each do |v|
        let!("line_item_#{v}".to_sym) do
          build_stubbed(:blank_line_item, name: "line_item_#{v}")
        end
      end

      it 'sorts them alphabetically' do
        expect([line_item_a, line_item_c, line_item_b].sort)
          .to eq [line_item_a, line_item_b, line_item_c]
      end
    end

    context 'on imprintable line items' do
      let!(:job)   { build_stubbed(:blank_job) }
      let!(:white) { build_stubbed(:blank_color, name: 'white') }
      let!(:shirt) { build_stubbed(:blank_imprintable) }
      make_stubbed_variants :white, :shirt, [:M, :S, :L]

      before(:each) do
        size_s.sort_order = 1
        size_m.sort_order = 2
        size_l.sort_order = 3
      end

      it 'sorts them by the size sort order' do
        expect(
          [white_shirt_m_item, white_shirt_l_item, white_shirt_s_item].sort
        )
          .to eq [white_shirt_s_item, white_shirt_m_item, white_shirt_l_item]
      end
    end
  end

  describe '#group_name=', story_303: true, pending: 'groups are GONE' do
    context 'when the line item is part of a quote' do
      let!(:quote) { create :valid_quote }
      let!(:line_item_attributes) { attributes_for :line_item, name: 'whee', description: 'important' }

      before(:each) do
        quote.line_items_attributes = { line_item: line_item_attributes }
      end

      context 'and the quote has a group of the given name' do
        before(:each) do
          quote.line_item_groups << create(:line_item_group, name: 'Test Group')
          quote.save!
        end

        it 'hops over to the existing group' do
          group = quote.line_item_groups.find_by(name: 'Test Group')
          line_item = quote.line_items.first
          original_group = line_item.line_itemable

          expect(group.line_items).to_not include line_item

          line_item.group_name = 'Test Group'
          line_item.save!

          expect(group.reload.line_items).to include line_item
          expect(original_group.reload.line_items).to_not include line_item
        end
      end
      context 'and the quote does not have a group of the given name' do
        before(:each) do
          quote.save!
        end

        it 'creates a new group within the quote with the given name' do
          line_item = quote.line_items.first

          line_item.group_name = 'New Group'
          line_item.save!

          expect(quote.line_item_groups.pluck(:name)).to include 'New Group'
          expect(line_item.line_itemable.name).to eq 'New Group'
        end
      end
    end
  end

  describe '#imprintable' do
    let(:line_item) do
      build_stubbed(
        :blank_line_item,
        imprintable_variant: build_stubbed(
          :blank_imprintable_variant,
          imprintable: build_stubbed(:blank_imprintable)
        )
      )
    end

    it 'returns the imprintable' do
      expect(line_item.imprintable)
        .to eq(line_item.imprintable_variant.imprintable)
    end
  end

  describe '#imprintable?' do
    let(:line_item) do
      build_stubbed(:blank_line_item, imprintable_variant_id: nil)
    end

    it 'returns true if imprintable_variant_id is not nil, else false' do
      expect(line_item.imprintable?).to be_falsey
    end
  end

  describe '#unit_price', story_560: true do
    let!(:line_item) do
      build_stubbed(
        :blank_line_item, imprintable_variant_id: nil,
        unit_price: 10,
        decoration_price: 7,
        imprintable_price: 2
      )
    end
    subject { line_item.unit_price }

    context 'when it is imprintable' do
      before do
        allow(line_item).to receive(:imprintable?).and_return true
      end

      # 7 + 2 = 9
      it { is_expected.to eq 9 }
    end

    context 'when it is not imprintable' do
      before do
        allow(line_item).to receive(:imprintable?).and_return false
      end

      it { is_expected.to eq 10 }
    end
  end

  describe '#size_display' do
    let(:line_item) do
      build_stubbed(:blank_line_item,

        imprintable_variant: build_stubbed(:blank_imprintable_variant,
          size: build_stubbed(:blank_size, display_value: 1)
        )
      )
      end

    it 'returns the size display_value' do
      expect(line_item.size_display).to eq(1)
    end
  end

  describe '#style_catalog_no' do
    let(:line_item) do
      build_stubbed(:blank_line_item,

        imprintable_variant: build_stubbed(:blank_imprintable_variant,

          imprintable: build_stubbed(:blank_imprintable,
            style_catalog_no: 5555
          )
        )
      )
    end

    it 'returns the imprintable style_catalog_no' do
      expect(line_item.style_catalog_no)
        .to eq(line_item.imprintable_variant.imprintable.style_catalog_no)
    end
  end

  describe '#style_name' do
    let(:line_item) do
      build_stubbed(:blank_line_item,

        imprintable_variant: build_stubbed(:blank_imprintable_variant,

          imprintable: build_stubbed(:blank_imprintable, style_name: 'Style')
        )
      )
    end

    it 'returns the imprintable style_name' do
      expect(line_item.style_name)
        .to eq(line_item.imprintable_variant.imprintable.style_name)
    end
  end

  describe '#total_price' do
    let(:line_item) do
      build_stubbed(:blank_line_item, unit_price: 1, quantity: 1)
    end

    it 'returns the total price of the line items' do
      expect(line_item.total_price).to eq(1)
    end
  end
end
