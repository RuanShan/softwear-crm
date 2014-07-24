require 'spec_helper'

describe 'quotes/_line_item_standard_form.html.erb', quote_spec: true do
  login_user

  let!(:quote) { create(:valid_quote) }
  let!(:line_item) { create(:non_imprintable_line_item) }
  before(:each) do
    assign(:quote, quote)
    form_for(line_item, url: line_item_path(line_item), builder: LancengFormBuilder) do |f|
      @f = f
    end
    render partial: 'quotes/line_item_standard_form', locals: { f: @f }
  end

  it 'should have have labels for line item attributes' do
    expect(rendered).to have_css('label', text: 'Name')
    expect(rendered).to have_css('label', text: 'Description')
    expect(rendered).to have_css('label', text: 'Taxable')
    expect(rendered).to have_css('label', text: 'Quantity')
    expect(rendered).to have_css('label', text: 'Unit Price')
  end

  it 'should have appropriate fields for line item attributes' do
    expect(rendered).to have_css('fieldset input', count: 6)
    expect(rendered).to have_css('fieldset textarea', count: 1)
  end
end
