require 'spec_helper'

describe "orders/new.html.erb" do
  it 'should display all appropriate fields for creating an order' do
  	render
  	within_form_for Order do
  		expect(rendered).to have_field_for :email
  		expect(rendered).to have_field_for :firstname
  		expect(rendered).to have_field_for :lastname
  		expect(rendered).to have_field_for :company
  		expect(rendered).to have_field_for :twitter
  		expect(rendered).to have_field_for :name
  		expect(rendered).to have_field_for :po
  		expect(rendered).to have_field_for :in_hand_by
  		expect(rendered).to have_field_for :terms
  		expect(rendered).to have_field_for :tax_exempt
  		expect(rendered).to have_field_for :tax_id_number
  		expect(rendered).to have_field_for :is_redo
  		expect(rendered).to have_field_for :redo_reason
  	end
  end
end
