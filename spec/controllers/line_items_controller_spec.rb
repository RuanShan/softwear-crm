require 'spec_helper'
include LineItemHelpers

describe LineItemsController, line_item_spec: true, dear_god: true do
  render_views
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe '#create' do
    context 'with an imprintable_id and a color_id' do
      let!(:job) { create(:job) }
      let!(:white) { create(:valid_color, name: 'white') }
      let!(:shirt) { create(:associated_imprintable) }
      make_variants :white, :shirt, [:S, :M, :L, :XL], not: [:job, :line_items]

      it 'creates line items for each relevant size' do
        post :create, job_id: job.id, imprintable_id: shirt.id, color_id: white.id
        json_response = JSON.parse response.body
        expect(json_response['result']).to eq 'success'
        expect(LineItem.where(imprintable_variant_id: white_shirt_s.id)).to exist
        expect(LineItem.where(imprintable_variant_id: white_shirt_m.id)).to exist
        expect(LineItem.where(imprintable_variant_id: white_shirt_l.id)).to exist
        expect(LineItem.where(imprintable_variant_id: white_shirt_xl.id)).to exist
        expect(LineItem.where(job_id: job.id)).to exist
      end
    end
  end

  describe '#destroy', destroy: true do
    context 'with a 4-size imprintable line item group' do
      let!(:job) { create(:job) }
      let!(:white) { create(:valid_color, name: 'white') }
      let!(:shirt) { create(:associated_imprintable) }
      make_variants :white, :shirt, [:S, :M, :L, :XL]

      it 'destroys them all when supplied with their ids' do
        line_items = job.line_items.to_a
        delete :destroy, ids: line_items.map { |e| e.id }

        json_response = JSON.parse response.body
        expect(json_response['result']).to eq 'success'

        line_items.each do |line_item|
          expect(LineItem.where(id: line_item.id)).to_not exist
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
        2.times { |i| let!("style#{i}".to_sym) { create(:style, brand_id: brand1.id) } }

        context 'when there are matching styles' do
          it 'responds with a select tag for styles', broken: true do
            get :select_options, brand_id: brand1.id
            expect(response.body).to include '<select'
            expect(response.body).to include style0.name
            expect(response.body).to include style1.name
          end
        end
        context 'where there are no matching styles' do
          it 'responds with error message html' do
            get :select_options, brand_id: brand0.id
            expect(response.body).to include "Couldn't find"
          end
        end

        context 'with style_id' do
          2.times { |i| let!("color#{i}".to_sym) { create(:valid_color) } }
          2.times { |i| let!("size#{i}".to_sym) { create(:valid_size) } }
          let!(:imp) { create(:associated_imprintable, style_id: style1.id) }

          let!(:iv0) { create(:associated_imprintable_variant, imprintable_id: imp.id, color_id: color0.id) }
          2.times { |i| let!("iv1_#{i}".to_sym) { create(:associated_imprintable_variant, 
            imprintable_id: imp.id,
            size_id: send("size#{i}").id,
            color_id: color1.id
          ) } }

          context 'when there are matching colors' do
            it 'responds with a select tag for colors' do
              get :select_options, style_id: style1.id
              expect(response.body).to include '<select'
              expect(response.body).to include color0.name
              expect(response.body).to include color1.name
            end
          end
          context 'when there are no matching colors' do
            it 'responds with error message html' do
              get :select_options, style_id: style0.id
              expect(response.body).to include "Couldn't find"
            end
          end

          context 'and color_id' do
            context 'when there are matching variants' do
              it 'responds with the name, description, and a list of sizes' do
                get :select_options, style_id: style1.id, color_id: color1.id
                expect(response.body).to include style1.name
                expect(response.body).to include style1.catalog_no
                expect(response.body).to include imp.description
                expect(response.body).to include size0.name
                expect(response.body).to include size1.name
              end
            end
            context 'when there is no matching variant' do
              it 'responds with error message html' do
                get :select_options, style_id: style0.id, color_id: color0.id
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