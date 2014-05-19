require 'spec_helper'

describe 'orders/_details.html.erb', order_spec: true do
  before :each do
  	render partial: 'orders/details', locals: { order: create(:order) }
  end

  it 'should display the commission amount and sales status fields' do
    within_form_for Order do
    	expect(rendered).to have_field_for :sales_status
      expect(rendered).to have_field_for :commission_amount
    end
  end

  it 'should have a save button' do
  	within_form_for Order do
  		expect(rendered).to have_css '.submit[value="Save"]'
  	end
  end
end
