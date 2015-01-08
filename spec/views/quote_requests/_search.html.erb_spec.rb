require 'spec_helper'

describe 'quote_requests/_search.html.erb', quote_request: true, story_207: true do

  before(:each) do
    render partial: 'quote_requests/search'
  end

  it 'has a select for filters, a text box for input, and a submit button' do
    expect(rendered).to have_css("input#js_search")
    expect(rendered).to have_css("select#quote_requests_search_filter")
    expect(rendered).to have_css("input.submit[value='Search']")
  end

end