require 'spec_helper'

describe FBA, fba_spec: true, story_103: true do
  describe '.parse_packing_slip' do
    let(:packing_slip) do
      File.new("#{Rails.root}/spec/fixtures/fba/TestPackingSlip.txt")
    end

    context 'when the appropritate records exist' do
      let!(:size_s) { create :valid_size, sku: '02' }
      let!(:size_m) { create :valid_size, sku: '03' }
      let!(:size_l) { create :valid_size, sku: '04' }
      let!(:size_xl) { create :valid_size, sku: '05' }
      let!(:color) { create :valid_color, sku: '000' }
      let!(:imprintable) { create :valid_imprintable, sku: '0705' }

      before :each do
        allow(ImprintableVariant).to receive(:size_variants_for)
          .and_return [size_s, size_m, size_l, size_xl]
          .map { |s| double('ImprintableVariant', size_id: s.id) }
      end

      it 'should return an instance of FBA' do
        expect(FBA.parse_packing_slip(packing_slip)).to be_a FBA
      end

      it 'assigns #job_name to the imprintable + shipment ID' do
        subject = FBA.parse_packing_slip(packing_slip)

        expect(subject.job_name).to eq 'fba_wedd_bride FBA237FK5S'
      end

      it 'assigns #colors to an array of structs with sizes/quantities' do
        subject = FBA.parse_packing_slip(packing_slip)

        expect(subject.colors.map(&:color)).to eq [color]
        expect(subject.colors.first.sizes.map(&:size))
          .to eq [size_s, size_m, size_l, size_xl]
        expect(subject.colors.first.sizes.map(&:quantity))
          .to eq %w(53 51 53 52)
      end

      it 'assigns #imprintable to the imprintable that will be in the job' do
        subject = FBA.parse_packing_slip(packing_slip)

        expect(subject.imprintable).to eq imprintable
      end

      it 'queries imprintable, color, and sizes based on the sku in the slip' do
        %w(02 03 04 05).each do |sku|
          expect(Size).to receive(:find_by).with(sku: sku)
        end
        expect(Color).to receive(:find_by).with(sku: '000')
        expect(Imprintable).to receive(:find_by).with(sku: '0705')

        FBA.parse_packing_slip(packing_slip)
      end

      it 'assigns #errors to an empty array' do
        expect(FBA.parse_packing_slip(packing_slip).errors).to eq []
      end
    end

    context 'when a size does not exist' do
      let(:other_size_s) { create :valid_size, sku: '22' }
      let!(:size_m) { create :valid_size, sku: '03' }
      let!(:size_l) { create :valid_size, sku: '04' }
      let!(:size_xl) { create :valid_size, sku: '05' }
      let!(:color) { create :valid_color, sku: '000' }
      let!(:imprintable) { create :valid_imprintable, sku: '0705' }

      before :each do
        allow(FBA).to receive(:find_errors).and_return []
      end

      it 'adds an error regarding the sku of the missing size' do
        subject = FBA.parse_packing_slip(packing_slip)

        expect(subject.errors.map(&:message))
          .to include "Couldn't find size with sku '02'"
      end

      context 'options: { sizes: { "02" => "50" } }', options: true do
        it 'uses size with id=50 for the size sku 02' do
          expect(Size).to receive(:find).with('50').and_return other_size_s

          FBA.parse_packing_slip(packing_slip, sizes: { "02" => "50" })
        end
      end
    end

    context 'when a color does not exist' do
      let!(:size_s) { create :valid_size, sku: '02' }
      let!(:size_m) { create :valid_size, sku: '03' }
      let!(:size_l) { create :valid_size, sku: '04' }
      let!(:size_xl) { create :valid_size, sku: '05' }
      let(:other_color) { create :valid_color, sku: '456' }
      let!(:imprintable) { create :valid_imprintable, sku: '0705' }

      before :each do
        # allow(FBA).to receive(:find_errors).and_return []
      end

      it 'adds an error regarding the sku of the missing color' do
        subject = FBA.parse_packing_slip(packing_slip)

        expect(subject.errors.map(&:message))
          .to include "Couldn't find color with sku '000'"
      end

      context 'options: { colors: { "000" => "50" } }', options: true do
        it 'uses color with id=50 for the color sku 000' do
          expect(Color).to_not receive(:find_by).with(sku: '456')
          expect(Color).to receive(:find).with('50').and_return other_color
          
          FBA.parse_packing_slip(packing_slip, colors: { "000" => "50" })
        end
      end
    end

    context 'when the imprintable does not exist' do
      let!(:size_s) { create :valid_size, sku: '02' }
      let!(:size_m) { create :valid_size, sku: '03' }
      let!(:size_l) { create :valid_size, sku: '04' }
      let!(:size_xl) { create :valid_size, sku: '05' }
      let!(:color) { create :valid_color, sku: '000' }
      let(:other_imprintable) { create :valid_imprintable, sku: '6489' }

      it 'adds an error regarding the sku of the missing imprintable' do
        subject = FBA.parse_packing_slip(packing_slip)

        expect(subject.errors.map(&:message))
          .to include "Couldn't find imprintable with sku '0705'"
      end

      context 'options: { imprintables: { "0705" => "50" } }', options: true, imp_opts: true do
        it 'uses imprintable with sku=50 instead of sku=0705' do
          expect(Imprintable).to_not receive(:find_by).with(sku: '0705')
          expect(Imprintable).to receive(:find_by).with(sku: '50')
            .and_return other_imprintable

          FBA.parse_packing_slip(packing_slip, 'imprintables' => { "0705" => "50" })
        end
      end
    end

    context 'when a size is invalid' do
      let!(:size_s) { build_stubbed :valid_size, sku: '02' }
      let!(:size_m) { build_stubbed :valid_size, sku: '03' }
      let!(:size_l) { build_stubbed :valid_size, sku: '04' }
      let!(:size_xl) { build_stubbed :valid_size, sku: '05' }
      let!(:color) { build_stubbed :valid_color, sku: '000' }
      let!(:imprintable) { build_stubbed :valid_imprintable, sku: '0705' }

      before :each do
        [size_s, size_m, size_l, size_xl, color, imprintable]
          .each_with_index do |object, count|
          allow(object).to receive(:id).and_return count
          allow(object.class).to receive(:find_by)
            .with({sku: object.sku}).and_return object
        end

        allow(ImprintableVariant).to receive(:size_variants_for)
          .and_return [size_s, size_l, size_xl]
          .map { |s| double('ImprintableVariant', size_id: s.id) }
      end

      it 'adds an error regarding the sku of the invalid size' do
        subject = FBA.parse_packing_slip(packing_slip)

        expect(subject.errors.map(&:type)).to include :invalid_size
      end
    end

    context 'when a sku is invalid', sku: true do
      context 'because of a bad version' do
        before :each do
          allow(FBA).to receive(:parse_sku).and_return nil
        end

        it 'adds a "Bad sku" error' do
          subject = FBA.parse_packing_slip(packing_slip)

          expect(subject.errors.flat_map(&:type)).to include :bad_sku
        end
      end
    end
  end

  context 'given valid packing slip information' do
    let!(:size_s) { build_stubbed :valid_size, sku: '02' }
    let!(:size_m) { build_stubbed :valid_size, sku: '03' }
    let!(:size_l) { build_stubbed :valid_size, sku: '04' }
    let!(:size_xl) { build_stubbed :valid_size, sku: '05' }
    let!(:color) { build_stubbed :valid_color, sku: '000' }
    let!(:imprintable) { build_stubbed :valid_imprintable, sku: '0705' }

    before :each do
      [size_s, size_m, size_l, size_xl, color, imprintable]
        .each_with_index do |object, count|
        allow(object).to receive(:id).and_return count
      end
    end

    let(:fba) do
      FBA.new(
        job_name:   'test_fba FBA222EE2E',
        imprintable: imprintable,

        colors: [FBA::Color.new(color, [
          FBA::Size.new(size_s, 10),
          FBA::Size.new(size_m, 11),
          FBA::Size.new(size_l, 12),
          FBA::Size.new(size_xl, 13)
        ])]
      )
    end

    describe '#to_h', to_h: true do
      let!(:size_s) { build_stubbed :valid_size, sku: '02' }
      let!(:size_m) { build_stubbed :valid_size, sku: '03' }
      let!(:size_l) { build_stubbed :valid_size, sku: '04' }
      let!(:size_xl) { build_stubbed :valid_size, sku: '05' }
      let!(:color) { build_stubbed :valid_color, sku: '000' }
      let!(:imprintable) { build_stubbed :valid_imprintable, sku: '0705' }
      
      it 'returns a hash representation of name/imprintables/colors/sizes' do
        subject = fba.to_h

        expect(subject).to eq({
          job_name: 'test_fba FBA222EE2E',
          imprintable: imprintable.id,
          colors: [
            {
              color: color.id,
              sizes: [
                {
                  size: size_s.id,
                  quantity: 10
                },
                {
                  size: size_m.id,
                  quantity: 11
                },
                {
                  size: size_l.id,
                  quantity: 12
                },
                {
                  size: size_xl.id,
                  quantity: 13
                }
              ]
            }
          ]
        })
      end
    end
  end
end
