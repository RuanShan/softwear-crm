require 'spec_helper'

describe 'orders/_order_customer_fields.html.erb', order_spec: true do
  it 'should display the correct fields' do
    order = create(:order)
    f = OrderFormBuilder.dummy_for order
    render partial: 'orders/customer_detail_fields', locals: { order: order, f: f }
    within_form_for Order, noscope: true do
      expect(rendered).to have_field_for :email
      expect(rendered).to have_field_for :firstname
      expect(rendered).to have_field_for :lastname
      expect(rendered).to have_field_for :company
      expect(rendered).to have_field_for :twitter
      expect(rendered).to have_field_for :phone_number
    end
  end
end
