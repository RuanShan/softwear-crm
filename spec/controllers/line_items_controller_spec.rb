require 'spec_helper'

describe LineItemsController, line_item_spec: true, dear_god: true do
	render_views

	describe '#options' do

		context 'when there are brands' do
			2.times { |i| let!("brand#{i}".to_sym) { create(:valid_brand) } }

			it 'responds with a select tag for brands' do
				get :options
				expect(response.body).to include '<select>'
				expect(response.body).to include brand0.name
				expect(response.body).to include brand1.name
			end

			context 'with brand_id' do
				2.times { |i| let!("style#{i}".to_sym) { create(:valid_style, brand_id: brand1.id) } }

				context 'when there are matching styles' do
					it 'responds with a select tag for styles' do
						get :options, brand_id: brand1.id
						expect(response.body).to include '<select>'
						expect(response.body).to include style0.name
						expect(response.body).to include style1.name
					end
				end
				context 'where there are no matching styles' do
					it 'responds with error message html' do
						get :options, brand_id: brand0.id
						expect(response.body).to include 'error'
					end
				end

				context 'with style_id' do
					2.times { |i| let!("style#{i}".to_sym) { create(:valid_style, brand_id: brand1.id) } }

					context 'when there are matching colors' do
						it 'responds with a select tag for colors'
					end
					context 'when there are no matching colors' do
						it 'responds with error message html'
					end

					context 'with color_id' do
						context 'when there is a matching variant' do
							it 'responds with an imprintable_variant JSON'
						end
						context 'when there is no matching variant' do
							it 'responds with error message html'
						end
					end
				end
			end
		end
		context 'when there are no brands' do
			it 'responds with error message html' do
				get :options
				expect(response.body).to include 'error'
			end
		end
	end
end