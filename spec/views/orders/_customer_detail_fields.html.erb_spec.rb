require 'spec_helper'

describe 'orders/_order_customer_fields.html.erb', order_spec: true do
  login_user

  it 'should display the correct fields' do
    order = create(:order)
    f = test_form_for order, builder: LancengFormBuilder
    render partial: 'orders/customer_detail_fields', locals: { order: order, f: f }
    within_form_for Order, noscope: true do
      expect(rendered).to have_field_for :email
      expect(rendered).to have_field_for :firstname
      expect(rendered).to have_field_for :lastname
      expect(rendered).to have_field_for :company
      expect(rendered).to have_field_for :twitter
      expect(rendered).to have_field_for :phone_number
      expect(rendered).to have_field_for :phone_number_extension
    end
  end
end
