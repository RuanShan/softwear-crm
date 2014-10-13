require 'spec_helper'

describe 'quotes/_quote_detail_fields.html.erb', quote_spec: true do
  login_user

  let!(:quote) { build_stubbed(:valid_quote) }

  before(:each) do
    form_for(quote, url: quote_path(quote), builder: LancengFormBuilder) do |f|
      @f = f
    end
    render partial: 'quotes/quote_detail_fields', locals: { f: @f, quote: quote }
  end

  it 'should contain all the necessary fields and labels' do
    expect(rendered).to have_css('label', text: 'Quote Name')
    expect(rendered).to have_css('input#quote_name')
    expect(rendered).to have_css('label', text: 'Quote source')
    expect(rendered).to have_css('select#quote_quote_source')
    expect(rendered).to have_css('label', text: 'Valid Until Date')
    expect(rendered).to have_css('input#quote_valid_until_date')
    expect(rendered).to have_css('label', text: 'Estimated Delivery Date')
    expect(rendered).to have_css('input#quote_estimated_delivery_date')
    expect(rendered).to have_css('label', text: 'Salesperson')
    expect(rendered).to have_css('select#quote_salesperson_id')
    expect(rendered).to have_css('label', text: 'Store')
    expect(rendered).to have_css('select#quote_store_id')
  end
end
