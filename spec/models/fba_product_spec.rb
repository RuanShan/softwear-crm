require 'spec_helper'
include LineItemHelpers

describe FbaProduct do
  describe '.create_from_spreadsheet' do
    context 'given a validly formatted spreadsheet' do
      let(:spreadsheet_path) { Rails.root.join "spec/fixtures/fba/fbaskus1.xlsx" }

      context 'when all of the referenced variants exist' do
        let!(:next_level) { create(:valid_brand, name: 'Next Level') }
        let!(:tultex) { create(:valid_brand, name: 'tultex') }

        let!(:shirt) { create(:associated_imprintable, style_catalog_no: 'N6210', brand: next_level) }
        let!(:sweater) { create(:associated_imprintable, style_catalog_no: '0202', brand: tultex) }

        let!(:royal) { create(:valid_color, name: 'Royal') }
        let!(:black) { create(:valid_color, name: 'Black') }

        let!(:adult_template) { create(:fba_job_template_with_imprint, name: 'Adult') }

        make_variants :royal, :shirt,   [:S, :M, :L, :XL, :XXL, :XXXL],      not: %i(line_item job)
        make_variants :black, :sweater, [:XS, :S, :M, :L, :XL, :XXL, :XXXL], not: %i(line_item job)

        it 'creates fba products with skus matching all of the data in the spreadsheet' do
          expect(FbaProduct.create_from_spreadsheet(spreadsheet_path)).to be_empty

          expect(FbaProduct.where(name: 'FBA - Vin Reagan - 2CF')).to exist
          expect(FbaProduct.where(name: 'FBA - Vin Reagan - 2CF', sku: 'fba_reagan84')).to exist
          expect(FbaProduct.where(name: 'FBA** - Tap Snap Color - 4CF')).to exist
          expect(FbaProduct.where(name: 'FBA** - Tap Snap Color - 4CF', sku: 'fba_tapsnap2')).to exist

          reagan = FbaProduct.find_by name: 'FBA - Vin Reagan - 2CF'
          expect(reagan.fba_skus.size).to eq 6

          expect(reagan.fba_skus.where(sku: '0-fba_reagan84-2030002002')).to exist
          expect(reagan.fba_skus.where(sku: '0-fba_reagan84-2030003002')).to exist
          expect(reagan.fba_skus.where(sku: '0-fba_reagan84-2030004002')).to exist
          expect(reagan.fba_skus.where(sku: '0-fba_reagan84-2030005002')).to exist
          expect(reagan.fba_skus.where(sku: '0-fba_reagan84-2030006002')).to exist
          expect(reagan.fba_skus.where(sku: '0-fba_reagan84-2030007002')).to exist

          expect(reagan.fba_skus.where(asin: 'B00L2ILWL0')).to exist
          expect(reagan.fba_skus.where(asin: 'B00L2IM0FC')).to exist
          expect(reagan.fba_skus.where(asin: 'B00L2IM64M')).to exist
          expect(reagan.fba_skus.where(asin: 'B00L2IMA4I')).to exist
          expect(reagan.fba_skus.where(asin: 'B00L2IME9Y')).to exist
          expect(reagan.fba_skus.where(asin: 'B00L2IMIG8')).to exist

          expect(reagan.fba_skus.where(fnsku: 'X000M30WOP')).to exist
          expect(reagan.fba_skus.where(fnsku: 'X000M30WRH')).to exist
          expect(reagan.fba_skus.where(fnsku: 'X000M30WSL')).to exist
          expect(reagan.fba_skus.where(fnsku: 'X000M30WQD')).to exist
          expect(reagan.fba_skus.where(fnsku: 'X000M30WS1')).to exist
          expect(reagan.fba_skus.where(fnsku: 'X000M30WQX')).to exist

          tapsnap = FbaProduct.find_by name: 'FBA** - Tap Snap Color - 4CF'
          expect(tapsnap.fba_skus.size).to eq 7

          expect(tapsnap.fba_skus.where(sku: '0-fba_tapsnap2-2010001001')).to exist
          expect(tapsnap.fba_skus.where(sku: '0-fba_tapsnap2-2010002001')).to exist
          expect(tapsnap.fba_skus.where(sku: '0-fba_tapsnap2-2010003001')).to exist
          expect(tapsnap.fba_skus.where(sku: '0-fba_tapsnap2-2010004001')).to exist
          expect(tapsnap.fba_skus.where(sku: '0-fba_tapsnap2-2010005001')).to exist
          expect(tapsnap.fba_skus.where(sku: '0-fba_tapsnap2-2010006001')).to exist
          expect(tapsnap.fba_skus.where(sku: '0-fba_tapsnap2-2010007001')).to exist

          expect(tapsnap.fba_skus.where(asin: 'B00WXLZ43M')).to exist
          expect(tapsnap.fba_skus.where(asin: 'B00WXLZBRG')).to exist
          expect(tapsnap.fba_skus.where(asin: 'B00WXLZMIE')).to exist
          expect(tapsnap.fba_skus.where(asin: 'B00WXLZTZU')).to exist
          expect(tapsnap.fba_skus.where(asin: 'B00WXM02B0')).to exist
          expect(tapsnap.fba_skus.where(asin: 'B00WXM0EJA')).to exist
          expect(tapsnap.fba_skus.where(asin: 'B00WXM0LT8')).to exist

          expect(tapsnap.fba_skus.where(fnsku: 'X000RPDNTT')).to exist
          expect(tapsnap.fba_skus.where(fnsku: 'X000RPDL3R')).to exist
          expect(tapsnap.fba_skus.where(fnsku: 'X000RPDKUL')).to exist
          expect(tapsnap.fba_skus.where(fnsku: 'X000RPDKSD')).to exist
          expect(tapsnap.fba_skus.where(fnsku: 'X000RPDPYR')).to exist
          expect(tapsnap.fba_skus.where(fnsku: 'X000RPDKZ1')).to exist
          expect(tapsnap.fba_skus.where(fnsku: 'X000RPDL55')).to exist
        end
      end
    end
  end
end
