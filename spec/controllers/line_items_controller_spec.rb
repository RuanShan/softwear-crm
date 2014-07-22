require 'spec_helper'
include LineItemHelpers

describe LineItemsController, line_item_spec: true do
  render_views
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe '#create' do
    context 'with an imprintable_id and a color_id' do
      let!(:job) { create(:job) }
      let!(:white) { create(:valid_color, name: 'white') }
      let!(:shirt) { create(:valid_imprintable) }
      make_variants :white, :shirt, [:S, :M, :L, :XL], not: [:job, :line_items]

      it 'creates line items for each relevant size' do
        post :create, job_id: job.id, imprintable_id: shirt.id, color_id: white.id
        json_response = JSON.parse response.body
        expect(json_response['result']).to eq 'success'
        expect(LineItem.where(imprintable_variant_id: white_shirt_s.id)).to exist
        expect(LineItem.where(imprintable_variant_id: white_shirt_m.id)).to exist
        expect(LineItem.where(imprintable_variant_id: white_shirt_l.id)).to exist
        expect(LineItem.where(imprintable_variant_id: white_shirt_xl.id)).to exist
        expect(LineItem.where(line_itemable_id: job.id, line_itemable_type: 'Job')).to exist
      end

      it 'only fires one public activity activity', activity_spec: true do
        PublicActivity.with_tracking do
          expect(PublicActivity::Activity.all.count).to eq 0
          post :create, job_id: job.id, imprintable_id: shirt.id, color_id: white.id
          expect(PublicActivity::Activity.all.count).to eq 1
        end
      end

      context 'and the job already has some line items' do
        before(:each) do
          job.line_items << white_shirt_m_item
          job.line_items << white_shirt_l_item
        end

        it "still succeeds and only adds new ones" do
          post :create, job_id: job.id, imprintable_id: shirt.id, color_id: white.id
          json_response = JSON.parse response.body
          expect(json_response['result']).to eq 'success'
          expect(LineItem.where(imprintable_variant_id: white_shirt_s.id)).to exist
          expect(LineItem.where(imprintable_variant_id: white_shirt_xl.id)).to exist
        end

        it 'fails when the job has all line items' do
          job.line_items << white_shirt_s_item
          job.line_items << white_shirt_xl_item
          post :create, job_id: job.id, imprintable_id: shirt.id, color_id: white.id
          json_response = JSON.parse response.body
          expect(json_response['result']).to eq 'failure'
        end
      end
    end
  end

  describe '#destroy', destroy: true do
    context 'with a 4-size imprintable line item group' do
      let!(:job) { create(:job) }
      let!(:white) { create(:valid_color, name: 'white') }
      let!(:shirt) { create(:valid_imprintable) }
      make_variants :white, :shirt, [:S, :M, :L, :XL]

      it 'destroys them all when supplied with their ids' do
        line_items = job.line_items.to_a
        delete :destroy, ids: line_items.map(&:id)

        json_response = JSON.parse response.body
        expect(json_response['result']).to eq 'success'

        line_items.each do |line_item|
          expect(LineItem.where(id: line_item.id)).to_not exist
        end
      end

      it 'only fires one activity', activity_spec: true do
        PublicActivity.with_tracking do
          expect(PublicActivity::Activity.all.count).to eq 0
          delete :destroy, ids: job.line_items.map(&:id)
          expect(PublicActivity::Activity.all.count).to eq 1
        end
      end
    end
  end

  describe '#select_options' do

    context 'when there are brands' do
      2.times { |i| let!("brand#{i}".to_sym) { create(:valid_brand) } }

      it 'responds with a select tag for brands' do
        get :select_options
        expect(response.body).to include '<select'
        expect(response.body).to include brand0.name
        expect(response.body).to include brand1.name
      end

      context 'with brand_id' do
        2.times { |i| let!("imprintable#{i}".to_sym) { create(:associated_imprintable, brand_id: brand1.id) } }

        context 'when there are matching styles' do
          it 'responds with a select tag for styles' do
            get :select_options, brand_id: brand1.id
            expect(response.body).to include '<select'
            expect(response.body).to include imprintable0.style_name
            expect(response.body).to include imprintable1.style_name
          end
        end
        context 'where there are no matching styles' do
          it 'responds with error message html' do
            get :select_options, brand_id: brand0.id
            expect(response.body).to include "Couldn't find"
          end
        end

        context 'with imprintable_id' do
          2.times { |i| let!("color#{i}".to_sym) { create(:valid_color) } }
          2.times { |i| let!("size#{i}".to_sym) { create(:valid_size) } }

          let!(:iv0) { create(:associated_imprintable_variant, imprintable_id: imprintable0.id, color_id: color0.id) }
          2.times { |i| let!("iv1_#{i}".to_sym) { create(:associated_imprintable_variant,
            imprintable_id: imprintable0.id,
            size_id: send("size#{i}").id,
            color_id: color1.id
          ) } }

          context 'when there are matching colors' do
            it 'responds with a select tag for colors' do
              get :select_options, imprintable_id: imprintable0.id
              expect(response.body).to include '<select'
              expect(response.body).to include color0.name
              expect(response.body).to include color1.name
            end
          end
          context 'when there are no matching colors' do
            it 'responds with error message html' do
              get :select_options, imprintable_id: imprintable1.id
              expect(response.body).to include "Couldn't find"
            end
          end

          context 'and color_id' do
            context 'when there are matching variants' do
              it 'responds with the name and description' do
                get :select_options, imprintable_id: imprintable0.id, color_id: color1.id
                expect(response.body).to include imprintable0.style_name
                expect(response.body).to include imprintable0.style_catalog_no
                expect(response.body).to include imprintable0.description
              end
            end
            context 'when there is no matching variant' do
              it 'responds with error message html' do
                get :select_options, imprintable_id: imprintable1.id, color_id: color0.id
                expect(response.body).to include "Couldn't find"
              end
            end
          end
        end
      end
    end
    context 'when there are no brands' do
      it 'responds with error message html' do
        get :select_options
        expect(response.body).to include "Couldn't find"
      end
    end
  end
end