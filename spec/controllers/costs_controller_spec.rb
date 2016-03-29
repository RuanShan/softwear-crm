require 'spec_helper'
include LineItemHelpers

describe CostsController do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe 'POST #mass_create' do
    context 'given a handful of params of the format "imprintable_variant_<id>_cost"' do
      let(:job) { create(:job) }
      let!(:white) { create(:valid_color, name: 'white') }
      let!(:shirt) { create(:valid_imprintable) }
      make_variants :white, :shirt, [:M, :S, :L]

      let!(:job_2) { create(:job) }
      let!(:white_shirt_s_item_2) { LineItem.create(white_shirt_s_item.attributes.merge(id: nil, job_id: job_2.id)) }
      let!(:white_shirt_m_item_2) { LineItem.create(white_shirt_m_item.attributes.merge(id: nil, job_id: job_2.id)) }
      let!(:white_shirt_l_item_2) { LineItem.create(white_shirt_l_item.attributes.merge(id: nil, job_id: job_2.id)) }

      let!(:creation_params) do
        {
          "imprintable_variant_#{white_shirt_s.id}_cost" => 10.5,
          "imprintable_variant_#{white_shirt_m.id}_cost" => 11.5,
          "imprintable_variant_#{white_shirt_l.id}_cost" => 12.5
        }
      end

      it 'creates costs for all line items of those variants' do
        expect(white_shirt_s_item.reload.cost_amount).to be_nil
        expect(white_shirt_m_item.reload.cost_amount).to be_nil
        expect(white_shirt_l_item.reload.cost_amount).to be_nil
        expect(white_shirt_s_item_2.reload.cost_amount).to be_nil
        expect(white_shirt_m_item_2.reload.cost_amount).to be_nil
        expect(white_shirt_l_item_2.reload.cost_amount).to be_nil

        post :mass_create, creation_params
        expect(flash[:error]).to be_blank
        expect(flash[:success]).to eq "Successfully added 6 costs!"

        expect(Cost.where(amount: 10.5)).to_not exist
        expect(Cost.where(amount: 11.5)).to_not exist
        expect(Cost.where(amount: 12.5)).to_not exist

        expect(white_shirt_s_item.reload.cost_amount).to eq 10.5
        expect(white_shirt_m_item.reload.cost_amount).to eq 11.5
        expect(white_shirt_l_item.reload.cost_amount).to eq 12.5
        expect(white_shirt_s_item_2.reload.cost_amount).to eq 10.5
        expect(white_shirt_m_item_2.reload.cost_amount).to eq 11.5
        expect(white_shirt_l_item_2.reload.cost_amount).to eq 12.5
      end
    end
  end
end
