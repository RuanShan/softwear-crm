require 'spec_helper'

describe 'quotes/_form.html.erb', quote_spec: true do
  login_user

  before(:each) do
    render partial: 'quotes/form', locals: { quote: build_stubbed(:valid_quote) }
  end

  it 'should have 3 sections' do
    expect(rendered).to have_css('section', count: 3)
  end

  context 'in the first section' do
    it 'should contain two divs of class col-sm-6, one with customer info. instructions' do
      expect(rendered).to have_css('section[data-step-title="Customer Information"] .col-sm-6', count: 2)
      expect(rendered).to have_css('section[data-step-title="Customer Information"] h4', text: 'Customer Information Instructions')
    end
  end

  context 'in the second section' do
    it 'should contain two divs of class col-sm-6, one with quote info. instructions' do
      expect(rendered).to have_css('section[data-step-title="Quote Details"] .col-sm-6', count: 2)
      expect(rendered).to have_css('section[data-step-title="Quote Details"] h4', text: 'Quote Information Instructions')
    end
  end

  context 'in the third section' do
    it 'should contain two divs of class col-sm-6, one with line items instructions' do
      expect(rendered).to have_css('section[data-step-title="Line Items"] .col-sm-6', count: 2)
      expect(rendered).to have_css('section[data-step-title="Line Items"] .notes', text: 'Line Items Instructions')
    end
  end
end
