require 'spec_helper'

describe 'sizes/_search.html.erb', size_spec: true, story_221: true do

  before(:each) do
    render partial: 'sizes/search'
  end

  it 'has  a text box for input and a submit button' do
    expect(rendered).to have_css("input#sizes_search")
    expect(rendered).to have_css("input.submit[value='Search']")
  end

end