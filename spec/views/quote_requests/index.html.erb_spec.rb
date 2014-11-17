require 'spec_helper'
require 'x-editable-rails/view_helpers'

describe 'quote_requests/index.html.erb',
         quote_request_spec: true, story_78: true, story_80: true, story_207: true do

  before(:each) do
    assign(:quote_requests, Kaminari.paginate_array([]).page(1))
    render
  end

  it 'has a table of quote requests and paginates them' do
    expect(rendered).to have_selector('table#quote-request-table')
    expect(rendered).to have_selector('div.pagination')
  end

  it 'renders the _table and _search partials' do
    expect(rendered).to render_template(partial: '_table')
    expect(rendered).to render_template(partial: '_search')
  end
end
