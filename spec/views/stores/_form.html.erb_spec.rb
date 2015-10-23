require 'spec_helper'

describe 'stores/_form.html.erb', store_spec: true do
  before(:each) do
    store = build_stubbed(:valid_store)
    f = test_form_for store, builder: LancengFormBuilder
    render partial: 'stores/form', locals: { store: store, f: f }
    end

  it 'has text_field for name and a submit button' do
    within_form_for Store, noscope: true do
      expect(rendered).to have_field_for :name
      expect(rendered).to have_field_for :address_1
      expect(rendered).to have_field_for :address_2
      expect(rendered).to have_field_for :zipcode
      expect(rendered).to have_field_for :city
      expect(rendered).to have_field_for :country
      expect(rendered).to have_field_for :phone
      expect(rendered).to have_field_for :sales_email
      expect(rendered).to have_selector("[type='submit']")
    end
  end
end
