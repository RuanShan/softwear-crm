require 'spec_helper'

describe "orders/_form.html.erb", order_spec: true do
  login_user

  let!(:render!) { ->(order) { render partial: 'orders/form', locals: { order: order } } }

  it 'should display all appropriate fields for creating an order' do
    order = create :order
    render!.(order)

  	within_form_for Order do
      expect(rendered).to have_selector 'a', text: 'Edit Contact'
      expect(rendered).to have_selector 'a', text: 'Change Contact'
  		expect(rendered).to have_field_for :company
  		expect(rendered).to have_field_for :name
  		expect(rendered).to have_field_for :po
  		expect(rendered).to have_field_for :in_hand_by
                expect(rendered).to have_field_for :store_id
  		expect(rendered).to have_field_for :terms
  		expect(rendered).to have_field_for :tax_exempt
  		expect(rendered).to have_field_for :tax_id_number
      expect(rendered).to have_field_for :delivery_method
      expect(rendered)
        .to_not have_selector 'input[type="hidden"][name="order[quote_ids][]"]'
  	end
  end

  context 'given a @quote_id' do
    it 'renders a hidden field for quote_ids[] with that id', story_48: true do
      order = build :order
      assign(:quote_id, 4)
      render!.(order)
      
      expect(rendered)
        .to have_selector 'input[type="hidden"][name="order[quote_ids][]"][value="4"]'
    end
  end
end
