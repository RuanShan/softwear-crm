require 'spec_helper'
include PricingModule
include LineItemHelpers

describe Imprintable, imprintable_spec: true do

  it_behaves_like 'retailable'

  it { is_expected.to be_paranoid }

  describe 'Relationship' do
    it { is_expected.to belong_to(:brand) }
    it { is_expected.to have_many(:colors).through(:imprintable_variants) }
    it { is_expected.to have_many(:coordinates).through(:coordinate_imprintables) }
    it { is_expected.to have_many(:coordinate_imprintables) }
    it { is_expected.to have_many(:imprintable_categories) }
    it { is_expected.to have_many(:imprintable_variants).dependent(:destroy) }
    it { is_expected.to have_many(:mirrored_coordinates).through(:mirrored_coordinate_imprintables) }
    it { is_expected.to have_many(:mirrored_coordinate_imprintables).class_name('CoordinateImprintable') }
    it { is_expected.to have_many(:sizes).through(:imprintable_variants) }
    it { is_expected.to have_and_belong_to_many(:compatible_imprint_methods) }
    it { is_expected.to have_and_belong_to_many(:sample_locations) }
    it { is_expected.to accept_nested_attributes_for(:imprintable_categories) }
    context 'story 554', story_554: true do
      it { is_expected.to have_many(:imprintable_imprintable_groups) }
      it { is_expected.to have_many(:imprintable_groups).through(:imprintable_imprintable_groups) }
    end

    context 'story 573', story_573: true do
      # Error message that shows up here is completely useless...
      # it { is_expected.to have_many(:similar_imprintables).through(:imprintable_groups).source(:imprintable) }
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:brand) }
#    it { is_expected.to validate_presence_of(:max_imprint_height) }
#    it { is_expected.to validate_numericality_of(:max_imprint_height) }
#    it { is_expected.to validate_presence_of(:max_imprint_width) }
#    it { is_expected.to validate_numericality_of(:max_imprint_width) }
    it { is_expected.to ensure_inclusion_of(:sizing_category).in_array Imprintable::SIZING_CATEGORIES }
    it { is_expected.to allow_value('http://www.foo.com', 'http://www.foo.com/shipping').for(:supplier_link) }
    it { is_expected.to_not allow_value('bad_url.com', '').for(:supplier_link).with_message('should be in format http://www.url.com/path') }
    it { is_expected.to validate_presence_of(:style_catalog_no) }
    it { is_expected.to validate_uniqueness_of(:style_catalog_no).scoped_to(:brand_id) }
    it { is_expected.to validate_presence_of(:style_name) }
    it { is_expected.to validate_uniqueness_of(:style_name).scoped_to(:brand_id) }

    context 'if retail' do
      before { allow(subject).to receive_message_chain(:is_retail?).and_return(true) }

      it { is_expected.to ensure_length_of(:sku).is_equal_to(4) }
    end

    context 'if not retail' do
      before { allow(subject).to receive_message_chain(:is_retail?).and_return(false) }

      it { is_expected.to_not ensure_length_of(:sku).is_equal_to(4) }
    end
  end

  describe 'Discontinue', story_595: :true do
    context 'when discontinued is set to true' do
      let!(:imprintable) { create(:valid_imprintable) }
      let!(:imprintable_group) { ImprintableGroup.create(name: "tig") }
      before{ create(:good, imprintable_id: imprintable.id, imprintable_group_id: imprintable_group.id) }
      it "is removed from all imprintable groups" do
        imprintable_group.reload
        expect(imprintable_group.imprintables).to include(imprintable)
        imprintable.discontinued = true
        imprintable.save
        imprintable_group.reload
        expect(imprintable_group.imprintables).not_to include(imprintable)
      end
    end
  end

  describe 'Scopes' do
    context 'there are two sizes, colors and variants' do
      let!(:color_one) { create(:valid_color) }
      let!(:color_two) { create(:valid_color) }
      let!(:size_one) { create(:valid_size) }
      let!(:size_two) { create(:valid_size) }
      let!(:imprintable) { create(:valid_imprintable) }
      let!(:imprintable_variant_one) { create(:valid_imprintable_variant) }
      let!(:imprintable_variant_two) { create(:valid_imprintable_variant) }

      before(:each) do
        imprintable_variant_one.imprintable_id = imprintable.id
        imprintable_variant_one.size_id = size_one.id
        imprintable_variant_one.color_id = color_one.id
        imprintable_variant_one.save

        imprintable_variant_two.imprintable_id = imprintable.id
        imprintable_variant_two.size_id = size_two.id
        imprintable_variant_two.color_id = color_two.id
        imprintable_variant_two.save
      end

      context 'there are two variants that have a common color' do
        it 'only return one color for the associated color' do
          imprintable_variant_two.color_id = color_one.id
          imprintable_variant_two.save
          expect(imprintable.colors.size).to eq(1)
        end
      end
      context 'there are two variants that have a common size' do
        it 'only returns one size for the associated size' do
          imprintable_variant_two.size_id = size_one.id
          imprintable_variant_two.save
          expect(imprintable.sizes.size).to eq(1)
        end
      end
    end
  end

  describe '#all_categories' do
    let(:imprintable) { build_stubbed(:blank_imprintable,
                                       imprintable_categories: [build_stubbed(:blank_imprintable_category, name: 'Category')])}

    it 'returns all of the categories for the imprintable' do
      expect(imprintable.all_categories).to eq('Category')
    end
  end

  describe '#create_imprintable_variants' do
    let(:sizes) { [create(:valid_size), create(:valid_size), create(:valid_size)] }
    let(:colors) { [create(:valid_color), create(:valid_color)] }
    let(:valid_imprintable) { create(:valid_imprintable) }

    context 'with valid input' do
      it 'generates an imprintable variant from arrays of sizes and colors' do
        expect(valid_imprintable.imprintable_variants.count).to eq(0)
        from_hash = {}
        from_hash[:sizes] = sizes
        from_hash[:colors] = colors
        valid_imprintable.create_imprintable_variants(from_hash)
        expect(valid_imprintable.imprintable_variants.count).to eq(6)
      end
    end

    context 'with invalid input' do
      it 'returns false' do
        from_hash = {}
        sizes = [create(:valid_size)]
        colors = [create(:valid_color)]
        sizes[0].id = 10
        from_hash[:sizes] = sizes
        from_hash[:colors] = colors
        expect(valid_imprintable.create_imprintable_variants(from_hash)).to be_falsey
      end
    end
  end

  describe '.set_model_collection_hash' do
    it 'instantiates a hash with brand, store, imprintable, size, color, imprint
        method collections as well as all colors and all sizes' do
      expect(Brand).to receive_message_chain(:order, :map).and_return 1
      expect(Store).to receive(:order).and_return 2
      expect(Imprintable).to receive(:all).and_return 3
      expect(Size).to receive(:order).and_return 4
      expect(Color).to receive(:order).and_return 5
      expect(ImprintMethod).to receive(:all).and_return 6
      expect(Color).to receive(:all).and_return 7
      expect(Size).to receive(:all).and_return 8

      expected_hash = {
        brand_collection: 1,
        store_collection: 2,
        imprintable_collection: 3,
        size_collection: 4,
        color_collection: 5,
        imprint_method_collection: 6,
        all_colors: 7,
        all_sizes: 8
      }
      test_hash = Imprintable.set_model_collection_hash
      expect(test_hash).to eq expected_hash
    end
  end

  describe '#create_variants_hash' do
    let!(:imprintable_variant) { create(:valid_imprintable_variant) }

    it 'returns the hashes that contain the size_id, color_id, and id of the associated imprintable_variant' do
      variants_hash = imprintable_variant.imprintable.create_variants_hash
      expect(variants_hash[:size_variants].first.id).to eq(imprintable_variant.size_id)
      expect(variants_hash[:color_variants].first.id).to eq(imprintable_variant.color_id)
      expect(variants_hash[:variants_array].first.id).to eq(imprintable_variant.id)
    end
  end

  describe '#description' do
    let!(:imprintable) { build_stubbed(:blank_imprintable, style_description: 'Description') }

    it 'returns the description for the associated style' do
      expect(imprintable.description).to eq("#{imprintable.style_description}")
    end
  end

  # TODO implement this
  describe '#determine_sizes'

  describe '#name' do
    let!(:imprintable) { build_stubbed(:blank_imprintable,
                                         brand: build_stubbed(:blank_brand, name: 'Brand'),
                                         style_catalog_no: 5555,
                                         style_name: 'Name') }

    it 'returns a string of the style.brand - style.catalog_no - style.name' do
      expect(imprintable.name).to eq("#{ imprintable.brand.name } - #{ imprintable.style_catalog_no } - #{ imprintable.style_name }")
    end
  end

  describe '#self.variants' do
    let!(:imprintable_variant) { create(:valid_imprintable_variant) }

    it 'returns the variant that is associated with the imprintable that it is called on' do
      expect(Imprintable.variants(imprintable_variant.imprintable.id).to_a.first).to eq(imprintable_variant)
    end
  end

  describe '#sizes_by_color', sizes_by_color: true do
    let!(:shirt) { create :valid_imprintable }

    let!(:red)   { create :valid_color, name: 'Red' }
    let!(:green) { create :valid_color, name: 'Green' }
    let!(:blue)  { create :valid_color, name: 'Blue' }

    make_variants :red, :shirt, [:s, :m, :l], not: [:line_item, :job]
    make_variants :green, :shirt, [:m, :l, :xl], not: [:line_item, :job]

    it 'returns the sizes for each imprintable variant matching the given color' do
      sizes = shirt.sizes_by_color 'Red'

      expect(sizes.map(&:name)).to_not be_empty
      expect(sizes.map(&:name)).to eq %w(s m l)
    end

    it 'takes 4 sql queries' do
      expect(queries_after { shirt.sizes_by_color 'Red' }).to eq 4
    end

    describe 'options' do
      it 'adds additional options to the query on sizes' do
        size_m.update_attributes retail: true
        expect(size_m.reload.retail).to eq true

        sizes = shirt.sizes_by_color 'Red', retail: true
        expect(sizes.map(&:name)).to eq ['m']
      end
    end
  end

  describe '#style_name_and_catalog_no' do
      let!(:imprintable) { build_stubbed(:blank_imprintable,
                                         style_catalog_no: 5555,
                                         style_name: 'Name') }

    it 'returns a string of the style_catalog_no - style_name' do
      expect(imprintable.style_name_and_catalog_no).to eq('5555 - Name')
    end
  end

  describe '#imprintable_variant_weight_for_size' do
    it 'returns the maximum imprintable variant weight for a given size (They should be uniform)'
  end

  describe '#update_weights_for_size' do
    it 'updates all imprintable variants of given size with weight'
  end

  describe '#base_price_ok=', story_205: true do
    let!(:imprintable) { create :valid_imprintable }

    context 'true' do
      it 'sets base_price to a non-nil value after saving' do
        imprintable.base_price = nil
        imprintable.save!
        expect(imprintable.reload.base_price).to be_nil

        imprintable.base_price_ok = true
        imprintable.base_price = 1.0
        imprintable.save!

        expect(imprintable.reload.base_price).to_not be_nil
      end
    end

    context 'false' do
      it 'sets base_price to nil after saving' do
        imprintable.base_price = 1.0
        imprintable.save!
        expect(imprintable.reload.base_price).to_not be_nil

        imprintable.base_price_ok = false
        imprintable.save!

        expect(imprintable.reload.base_price).to be_nil
      end
    end
  end

end

