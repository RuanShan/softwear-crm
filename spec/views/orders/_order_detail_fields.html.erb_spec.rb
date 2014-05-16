require 'spec_helper'

describe 'orders/_order_detail_fields.html.erb', order_spec: true do
  it 'should display the correct fields' do
    order = create(:order)
    f = OrderFormBuilder.dummy_for order
    render partial: 'orders/order_detail_fields', locals: { order: order, f: f }
    within_form_for Order, noscope: true do
      expect(rendered).to have_field_for :name
      expect(rendered).to have_field_for :po
      expect(rendered).to have_field_for :in_hand_by
      expect(rendered).to have_field_for :terms
      expect(rendered).to have_field_for :tax_exempt
      expect(rendered).to have_field_for :is_redo
    end
  end
end
