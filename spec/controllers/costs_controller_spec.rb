require 'spec_helper'
include LineItemHelpers

describe CostsController do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe 'POST #mass_create' do
    context 'given a handful of params of the format "line_item_<id>_cost"' do
      let(:job) { create(:job) }
      let!(:white) { create(:valid_color, name: 'white') }
      let!(:shirt) { create(:valid_imprintable) }
      make_variants :white, :shirt, [:M, :S, :L]

      let!(:creation_params) do
        {
          "line_item_#{white_shirt_s_item.id}_cost" => 10.5,
          "line_item_#{white_shirt_m_item.id}_cost" => 11.5,
          "line_item_#{white_shirt_l_item.id}_cost" => 12.5
        }
      end

      it 'creates costs for those line items' do
        expect(white_shirt_s_item.reload.cost).to be_nil
        expect(white_shirt_m_item.reload.cost).to be_nil
        expect(white_shirt_l_item.reload.cost).to be_nil

        post :mass_create, creation_params
        expect(flash[:error]).to be_blank
        expect(flash[:success]).to eq "Successfully added 3 costs!"

        expect(Cost.where(amount: 10.5)).to exist
        expect(Cost.where(amount: 11.5)).to exist
        expect(Cost.where(amount: 12.5)).to exist

        expect(white_shirt_s_item.reload.cost.amount).to eq 10.5
        expect(white_shirt_m_item.reload.cost.amount).to eq 11.5
        expect(white_shirt_l_item.reload.cost.amount).to eq 12.5
      end

      it 'calls ImprintableVariant.enqueue_update_last_costs' do
        expect(ImprintableVariant).to receive(:enqueue_update_last_costs)
          .with([white_shirt_s_item.id, white_shirt_m_item.id, white_shirt_l_item.id])

        post :mass_create, creation_params
      end
    end
  end
end
