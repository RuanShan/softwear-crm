require 'spec_helper'
include LineItemHelpers

describe LineItem, line_item_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:job) }
  end

  describe 'Validations', now: true do
    describe 'quantity' do
      before do
        allow(subject)
          .to receive_message_chain(:line_itemable, :try)
          .with(:jobbable_type)
          .and_return 'Quote'
      end

      it { is_expected.to validate_presence_of :quantity }
      it { is_expected.to allow_value(5).for :quantity }
      it { is_expected.to_not allow_value(-4).for :quantity }

      context 'when an order line item' do
        before do
          allow(subject)
            .to receive_message_chain(:line_itemable, :try) #(jobbable_type)
            .with(:jobbable_type)
            .and_return 'Order'
        end

        it { is_expected.to allow_value(0).for :quantity }
        it { is_expected.to_not allow_value(-4).for :quantity }
      end
    
      context 'in a job with line items' do
        let!(:white) { create(:valid_color, name: 'white') }
        let!(:shirt) { create(:valid_imprintable) }

        make_variants :white, :shirt, [:S, :M, :L]

        let!(:job) { create(:order_job) }
        subject { white_shirt_s_item }
        let(:variant) { subject.imprintable_object }
        let!(:imprint) { create(:imprint_with_name_number, job_id: subject.job_id) }
        let(:name_number) { create(:name_number, imprintable_variant_id: variant.id, imprint_id: imprint.id) }

        it 'should be >= amount of name/numbers' do
          subject.update_column :quantity, 1
          name_number
          expect(subject).to be_valid

          subject.quantity = 0
          expect(subject).to_not be_valid
        end
      end
    end
  

    context 'when imprintable_object is nil' do
      before :each do
        allow(subject).to receive(:imprintable_object_id).and_return nil
        allow(subject).to receive(:imprintable_object_type).and_return nil
      end

      it { is_expected.to validate_presence_of :description }
      it { is_expected.to validate_presence_of :name }
      it { is_expected.to validate_presence_of :unit_price }

      it 'description returns the description stored in the database' do
        expect(subject.description).to eq subject[:description]
      end

      it 'name returns the name stored in the database' do
        expect(subject.name).to eq subject[:name]
      end
    end

    context 'when imprintable_object_id is not nil' do
      subject do
        create(
          :imprintable_line_item,
          imprintable_object: create(:associated_imprintable_variant)
        )
      end

      it { is_expected.to_not validate_presence_of :description }
      it { is_expected.to_not validate_presence_of :name }
      it { is_expected.to validate_presence_of :decoration_price }
      it { is_expected.to validate_presence_of :imprintable_price }

      it 'description should return the imprintable_variant description' do
        expect(subject.description)
          .to eq subject.imprintable.style_description
      end
      context 'name', story_610: true do
        context 'when belonging to a quote job' do
          subject do
            create(
              :imprintable_line_item,
              imprintable_object: create(:valid_imprintable)
            )
          end

          before do
            allow(subject).to receive(:line_itemable)
             .and_return OpenStruct.new(jobbable_type: 'Quote')
          end

          it 'should return imprintable (not variant) name' do
            expect(subject.name).to eq subject.imprintable.name
          end
        end
        context 'when belonging to an order job' do
          before do
            allow(subject).to receive(:line_itemable)
             .and_return OpenStruct.new(jobbable_type: 'Order')
          end

          it 'should return imprintable variant name' do
            expect(subject.name).to eq subject.imprintable_variant.name
          end
        end
      end
      it 'name should return the name of its imprintable_variant' do
        expect(subject.name).to eq subject.imprintable_variant.name
      end
    end

    describe 'unit_price' do
      it { is_expected.to allow_value(51.21).for :unit_price }
      it { is_expected.to allow_value(12.2).for :unit_price }
      it { is_expected.to allow_value(3).for :unit_price }
    end
  end

  describe '.new_imprintables', new_imprintables: true do
    let!(:color) { create(:valid_color) }
    let!(:size_xl)  { create(:valid_size, name: 'xl',  display_value: 'XL', upcharge_group: 'base_price') }
    let!(:size_xxl) { create(:valid_size, name: 'xxl', display_value: '2XL', upcharge_group: 'xxl_price') }
    let!(:imprintable) { create(:associated_imprintable, base_price: 5.00, xxl_price: 10.00) }
    let!(:imprintable_variant_1) { create(:associated_imprintable_variant, imprintable: imprintable, size: size_xl, color: color) }
    let!(:imprintable_variant_2) { create(:associated_imprintable_variant, imprintable: imprintable, size: size_xxl, color: color) }
    let!(:job) { create(:job) }

    context 'passed an imprintable with sizes that have upcharge_groups' do
      it 'offsets the imprintable price by the matching upcharge group' do
        line_items = LineItem.new_imprintables(job, imprintable, color, imprintable_price: 10.00)

        expect(line_items.first.imprintable_price).to eq 5.00
        expect(line_items.last.imprintable_price).to eq 10.00
      end

      it 'offsets 6xl groups with the highest existing upcharge' do
        size_xxl.update_column :upcharge_group, 'xxxxl_price'
        line_items = LineItem.new_imprintables(job, imprintable, color, imprintable_price: 10.00)

        expect(line_items.first.imprintable_price).to eq 5.00
        expect(line_items.last.imprintable_price).to eq 10.00
      end
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

  describe '#imprintable' do
    let(:line_item) do
      build_stubbed(
        :blank_line_item,
        line_itemable: build_stubbed(:order_job),

        imprintable_object: build_stubbed(
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
    let!(:dummy_job) { double('Job', jobbable_type: 'Quote') }

    let!(:line_item) do
      build_stubbed(
        :blank_line_item, imprintable_variant_id: nil,
        unit_price: 10,
        decoration_price: 7,
        imprintable_price: 2
      )
    end
    subject { line_item.unit_price }

    context 'when it is imprintable and belongs to a quote' do
      before do
        allow(line_item).to receive(:imprintable?).and_return true
        allow(line_item).to receive(:line_itemable).and_return dummy_job
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
        line_itemable: build_stubbed(:order_job),

        imprintable_object: build_stubbed(:blank_imprintable_variant,
          size: build_stubbed(:blank_size, display_value: 1)
        )
      )
      end

    it 'returns the size display_value' do
      expect(line_item.size_display).to eq('1')
    end
  end

  describe '#style_catalog_no' do
    let(:line_item) do
      build_stubbed(:blank_line_item,
        line_itemable: build_stubbed(:order_job),

        imprintable_object: build_stubbed(:blank_imprintable_variant,

          imprintable: build_stubbed(:blank_imprintable,
            style_catalog_no: 5555
          )
        )
      )
    end

    it 'returns the imprintable style_catalog_no' do
      expect(line_item.style_catalog_no)
        .to eq(line_item.imprintable.style_catalog_no)
    end
  end

  describe '#style_name' do
    let(:line_item) do
      build_stubbed(:blank_line_item,
        line_itemable: build_stubbed(:order_job),

        imprintable_object: build_stubbed(:blank_imprintable_variant,

          imprintable: build_stubbed(:blank_imprintable, style_name: 'Style')
        )
      )
    end

    it 'returns the imprintable style_name' do
      expect(line_item.style_name)
        .to eq(line_item.imprintable.style_name)
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

  describe '#markup_or_option?', story_797: true do
    let!(:line_item) do
      build_stubbed(:blank_line_item, unit_price: 1, quantity: 1)
    end

    it 'returns true when the quantity is equal to MARKUP_ITEM_QUANTITY' do
      line_item.quantity = LineItem::MARKUP_ITEM_QUANTITY
      expect(line_item.markup_or_option?).to eq true
    end

    it 'returns true when the quantity is equal to MARKUP_ITEM_QUANTITY' do
      expect(line_item.markup_or_option?).to eq false
    end
  end
end
