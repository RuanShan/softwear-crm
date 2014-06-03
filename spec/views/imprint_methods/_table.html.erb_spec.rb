require 'spec_helper'

describe 'imprint_methods/_table.html.erb' do

  let(:imprint_methods){ [create(:valid_imprint_method)] }

  it 'has a table with the name, tracking url, and actions' do
    render partial: 'imprint_methods/table', locals: {imprint_methods: imprint_methods}
    expect(rendered).to have_selector('th', text: 'Name')
    expect(rendered).to have_selector('th', text: 'Production Name')
    expect(rendered).to have_selector('th', text: 'Actions')
  end

  it 'actions column has a link to edit and a link to destroy' do
    render partial: 'imprint_methods/table', locals: {imprint_methods: imprint_methods}
    expect(rendered).to have_selector("tr#imprint_method_#{imprint_methods.first.id} td a[href='#{edit_imprint_method_path(imprint_methods.first)}']")
    expect(rendered).to have_selector("tr#imprint_method_#{imprint_methods.first.id} td a[href='#{imprint_method_path(imprint_methods.first)}']")
  end
end