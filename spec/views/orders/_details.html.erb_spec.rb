require 'spec_helper'

describe 'orders/_details.html.erb', order_spec: true, wip: true do
  it 'should display the commission amount and sales status fields' do
    render partial: 'orders/details', locals: { order: create(:order) }
    within_form_for Order do
    	expect(rendered).to have_field_for :sales_status
      expect(rendered).to have_field_for :commission_amount
    end
  end
end
