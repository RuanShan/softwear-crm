require 'spec_helper'

describe 'imprint_methods/edit.html.erb' do
  let(:imprint_method){ create(:valid_imprint_method) }

  it 'has a form to create a new mockup group' do
    assign(:imprint_method, imprint_method)
    render file: 'imprint_methods/edit', id: imprint_method.to_param
    expect(rendered).to have_selector("form[action='#{imprint_method_path(imprint_method)}'][method='post']")
  end
end