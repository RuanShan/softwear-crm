require 'spec_helper'

describe 'imprintables/index.html.erb', imprintable_spec: true do

  before(:each) do
    assign(:imprintables, Kaminari.paginate_array([]).page(1))
    render
  end

  it 'has a table of imprintables and paginates them' do
    expect(rendered).to have_selector('table#imprintables_list')
    expect(rendered).to have_selector('div.pagination')
  end
end
