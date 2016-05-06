require 'spec_helper'

describe 'orders/_order_detail_fields.html.erb', order_spec: true do
  login_user

  let!(:order) { create :order }
  let!(:f) { test_form_for order, builder: LancengFormBuilder }
  let(:render!) { render partial: 'orders/order_detail_fields', locals: {  order: order, f: f, current_user: create(:user), show_quotes: true } }

  it 'should display the correct fields' do
    render!
    within_form_for Order, noscope: true do
      expect(rendered).to have_field_for :name
      expect(rendered).to have_field_for :po
      expect(rendered).to have_field_for :terms
      expect(rendered).to have_field_for :tax_exempt
      expect(rendered).to have_field_for :store_id
      expect(rendered).to have_field_for :salesperson_id
      expect(rendered).to have_field_for :invoice_state
      expect(rendered).to have_field_for :freshdesk_proof_ticket_id
      expect(rendered).to have_field_for :imported_from_admin
    end
  end

  it 'contain a select field for quotes', story_48: true do
    render!
    within_form_for Order, noscope: true do
      expect(rendered).to have_field_for :quote_ids
    end
  end
end
