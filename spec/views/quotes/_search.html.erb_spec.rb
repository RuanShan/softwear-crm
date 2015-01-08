require 'spec_helper'

describe 'quotes/_search.html.erb', quote_request: true, story_305: true do

  before(:each) do
    render partial: 'quotes/search'
  end

  it 'has  a text box for input and a submit button' do
    expect(rendered).to have_css("input#quotes_search")
    expect(rendered).to have_css("input.submit[value='Search']")
  end

end