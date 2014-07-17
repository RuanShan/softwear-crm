require 'spec_helper'

describe 'line_items/select_options.html.erb', line_item_spec: true do
	[Brand, Imprintable, Color].each do |type|
		context "with #{type.name.pluralize}" do
			5.times { |n| let!("object#{n}".to_sym) { create "valid_#{type.name.underscore}".to_sym } }

			it "renders a select field for the #{type.name.pluralize}" do
		  	render template: 'line_items/select_options', locals: { objects: type.all, type_name: type.name }, layout: nil

		  	expect(rendered).to have_css "select[name='#{type.name.underscore}_id']"
		  	expect(rendered).to have_css "label[for='#{type.name.underscore}_id']", text: type.name
		  	type.all.each do |object|
		  		expect(rendered).to have_css "option[value='#{object.id}']"
		  	end
		  end
		end
	end

	context 'when there are no objects' do
		it 'apologizes' do
			render template: 'line_items/select_options', locals: { objects: Brand.all, type_name: Brand.name }, layout: nil
			expect(rendered).to_not have_css 'select'
			expect(rendered).to have_css '*', text: "Couldn't find"
			expect(rendered).to have_css '*', text: 'Brands'
		end
	end
end