require 'spec_helper'

describe 'quotes/_quote_detail_fields.html.erb', quote_spec: true do
  login_user

  let!(:quote) { build_stubbed(:valid_quote) }

  before(:each) do
    form_for(quote, url: quote_path(quote), builder: LancengFormBuilder) { |f| @f = f }
  end

  it 'should contain all the necessary fields and labels', story_70: true do 
    render partial: 'quotes/quote_detail_fields', locals: { f: @f, quote: quote, quote_request_id: nil }
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
    expect(rendered).to have_css('label', text: 'Freshdesk Ticket ID')
    expect(rendered).to have_css('input#quote_freshdesk_ticket_id')
    expect(rendered).to have_css('label', text: 'Did the Customer Request a Specific Deadline?')
    expect(rendered).to have_css('label', text: 'Is this a rush job?')
  end

  context 'a deadline is specified' do
   # before(:each){ quote.do..whatever..here }

    it 'label for estimated_delivery_date to be Delivery date' do 
      render partial: 'quotes/quote_detail_fields', locals: { f: @f, quote: quote, quote_request_id: nil }
      expect(rendered).to have_css("label", text: "Delivery Date")
    end

  end
  
  context 'a deadline is not specified' do 

    it 'label for estimated_delivery_date to be Estimated Delivery date' do 
      quote.deadline_is_specified = false
      render partial: 'quotes/quote_detail_fields', locals: { f: @f, quote: quote, quote_request_id: nil }
      expect(rendered).to have_css("label", text: "Delivery Date")
    end

  end 

end
