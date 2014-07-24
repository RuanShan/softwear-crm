require 'spec_helper'

describe 'quotes/_line_item_fields.html.erb', quote_spec: true do
  let!(:quote) { create(:valid_quote) }
  let!(:line_item) { create(:non_imprintable_line_item) }

  login_user

  before(:each) do
    assign(:quote, quote)
    form_for(line_item, url: line_item_path(line_item), builder: LancengFormBuilder) do |f|
      @f = f
    end
    render partial: 'quotes/line_item_fields', locals: { f: @f }
  end

  it 'should display all of the basic information regarding the imprintable' do
    expect(rendered).to have_css('a.remove_fields', text: 'Remove Line Item')
  end
end
