require 'spec_helper'

describe 'imprintables/edit.html.erb', imprintable_spec: true do
  let(:imprintable){ create(:valid_imprintable) }

  it 'has a form to create a new mockup group' do
    assign(:imprintable, imprintable)
    render file: 'imprintables/edit', id: imprintable.to_param
    expect(rendered).to have_selector("form[action='#{imprintable_path(imprintable)}'][method='post']")
  end
end
