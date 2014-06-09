require 'spec_helper'

describe 'imprintables/index.html.erb' do


  it 'has a table of imprintables' do
    assign(:imprintables, Imprintable.all)
    render
    expect(rendered).to have_selector("table#imprintables_list")
  end
end
