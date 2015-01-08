require 'spec_helper'

describe 'colors/_search.html.erb', color_spec: true, story_221: true do

  before(:each) do
    render partial: 'colors/search'
  end

  it 'has  a text box for input and a submit button' do
    expect(rendered).to have_css("input#colors_search")
    expect(rendered).to have_css("input.submit[value='Search']")
  end

end