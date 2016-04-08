require 'spec_helper'
include LineItemHelpers

describe NameNumber, name_number_spec: true do
  describe 'Relationships' do
    context 'when testing story_189', story_189: true do
      it { is_expected.to belong_to :imprint }
      it { is_expected.to belong_to :imprintable_variant }
    end
  end

  describe 'Validations' do
    context 'when testing story_190', story_190: true do
      it { is_expected.to validate_presence_of :imprint_id }
      it { is_expected.to validate_presence_of :imprintable_variant_id }
    end

    context 'when in a job with line items' do
      let!(:white) { create(:valid_color, name: 'white') }
      let!(:shirt) { create(:valid_imprintable) }

      make_variants :white, :shirt, [:S, :M, :L]

      let!(:job) { create(:order_job) }
      let!(:line_item) { white_shirt_s_item }
      let(:variant) { line_item.imprintable_object }
      let!(:imprint) { create(:imprint_with_name_number, job_id: line_item.job_id) }
      subject { build(:name_number, imprintable_variant_id: variant.id, imprint_id: imprint.id) }

      context 'number of name/numbers is >= line item quantity' do
        before(:each) { line_item.update_column :quantity, 0 }

        it { is_expected.to_not be_valid }
      end

      context 'number of name/numbers is less than line item quantity' do
        before(:each) { line_item.update_column :quantity, 1 }

        it { is_expected.to be_valid }
      end
    end
  end
end
