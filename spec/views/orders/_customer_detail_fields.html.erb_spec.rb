require 'spec_helper'

describe 'orders/_order_customer_fields.html.erb', order_spec: true, wip: true do
  it 'should display the correct fields' do
    render partial: 'orders/customer_detail_fields', locals: { order: create(:order) }
    within_form_for Order do
      expect(rendered).to have_field_for :email
      expect(rendered).to have_field_for :firstname
      expect(rendered).to have_field_for :lastname
      expect(rendered).to have_field_for :company
      expect(rendered).to have_field_for :twitter
      expect(rendered).to have_field_for :phone_number
    end
  end
end
