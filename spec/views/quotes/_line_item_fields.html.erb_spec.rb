require 'spec_helper'

describe 'quotes/_line_item_fields.html.erb', quote_spec: true, story_75: true do
  let!(:quote) { build_stubbed(:valid_quote) }
  let!(:line_item) { build_stubbed(:non_imprintable_line_item) }

  before(:each) do
    assign(:quote, quote)
    form_for(line_item, url: line_item_path(line_item), builder: LancengFormBuilder) do |f|
      @f = f
    end
    render partial: 'quotes/line_item_fields', locals: { f: @f }
  end

  it 'should display all of the basic information regarding the imprintable' do
    expect(rendered).to have_css('a.js-remove-fields', text: 'Remove Line Item')
  end

  it 'should have have labels for line item attributes' do
    expect(rendered).to have_css('label', text: 'Name')
    expect(rendered).to have_css('label', text: 'Description')
    expect(rendered).to have_css('label', text: 'Taxable')
    expect(rendered).to have_css('label', text: 'Qty')
    expect(rendered).to have_css('label', text: 'Unit Price')
    expect(rendered).to have_css('label', text: 'URL')
  end
end
