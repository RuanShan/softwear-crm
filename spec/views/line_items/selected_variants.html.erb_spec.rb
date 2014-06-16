require 'spec_helper'
include LineItemHelpers

describe 'line_items/selected_variants.html.erb', line_item_spec: true do
  context 'with imprintable variants' do
  	let!(:white) { create(:valid_color, name: 'white') }
  	let(:shirt) { create(:valid_imprintable) }
  	make_variants :white, :shirt, [:S, :M, :L, :XL], not: [:job, :line_items]

  	before(:each) do
  		render template: 'line_items/selected_variants', locals: { 
  			objects: ImprintableVariant.where(
  				color_id: white.id,
  				imprintable_id: shirt.id
  		)}
  	end

  	it 'displays the name and description' do
  		expect(rendered).to include shirt.style.catalog_no
  		expect(rendered).to include shirt.style.name
  		expect(rendered).to include shirt.description
  	end

  	it 'renders a hidden field for the imprintable_id' do
  		expect(rendered).to have_css(
  			"input[type='hidden'][name='imprintable_id'][value='#{shirt.id}']"
  		)
  	end
  	it 'renders a hidden field for the color_id' do
  		expect(rendered).to have_css(
  			"input[type='hidden'][name='color_id'][value='#{white.id}']"
  		)
  	end
  end

  context 'with no imprintable variants' do
  	before(:each) do
  		render template: 'line_items/selected_variants', locals: {
  			objects: []
  		}
  	end

  	it 'apologizes' do
  		expect(rendered).to include "Couldn't find"
  	end
  end
end