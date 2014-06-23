require 'spec_helper'

describe 'stores/_form.html.erb', store_spec: true do
  before(:each){ render partial: 'stores/form', locals: { store: Store.new}}

  it 'has text_field for name and a submit button' do
    store = Store.new
    f = LancengFormBuilder.dummy_for store
    render partial: 'stores/form', locals: {store: store, f: f}
    within_form_for Store, noscope: true do
      expect(rendered).to have_field_for :name
      expect(rendered).to have_field_for :retail
      expect(rendered).to have_selector("[type='submit']")
    end
  end
end