require 'spec_helper'

describe 'orders/_order_detail_fields.html.erb', order_spec: true do
  login_user

  it 'should display the correct fields' do
    order = create(:order)
    f = test_form_for order, builder: LancengFormBuilder
    render partial: 'orders/order_detail_fields', locals: { order: order, f: f, current_user: create(:user) }
    within_form_for Order, noscope: true do
      expect(rendered).to have_field_for :name
      expect(rendered).to have_field_for :po
      expect(rendered).to have_field_for :in_hand_by
      expect(rendered).to have_field_for :terms
      expect(rendered).to have_field_for :tax_exempt
      expect(rendered).to have_field_for :store_id
      expect(rendered).to have_field_for :salesperson_id
    end
  end
end
