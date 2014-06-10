require 'spec_helper'

describe 'imprintables/new.html.erb', imprintable_spec: true do
  it 'has a form to create a new imprintable' do
    assign(:imprintable, Imprintable.new)
    render
    expect(rendered).to have_selector("form[action='#{imprintables_path}'][method='post']")
  end
end