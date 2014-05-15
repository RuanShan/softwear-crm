require 'spec_helper'

describe 'orders/_order_detail_fields.html.erb', order_spec: true, wip: true do
  it 'should display the correct fields' do
    render partial: 'orders/order_detail_fields', locals: { order: create(:order) }
    within_form_for Order do
      expect(rendered).to have_field_for :name
      expect(rendered).to have_field_for :po
      expect(rendered).to have_field_for :in_hand_by
      expect(rendered).to have_field_for :terms
      expect(rendered).to have_field_for :tax_exempt
      expect(rendered).to have_field_for :is_redo
    end
  end
end
