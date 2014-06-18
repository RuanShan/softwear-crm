require 'spec_helper'

describe 'stores/edit.html.erb', store_spec: true do
  let(:store){ create(:valid_store) }

  it 'has a form to create a new mockup group' do
    assign(:store, store)
    render file: 'stores/edit', id: store.to_param
    expect(rendered).to have_selector("form[action='#{store_path(store)}'][method='post']")
  end
end