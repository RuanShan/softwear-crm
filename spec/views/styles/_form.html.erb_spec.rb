require 'spec_helper'

describe 'styles/_form.html.erb', style_spec: true do
  before(:each){ render partial: 'styles/form', locals: { style: Style.new}}

  it 'has text_field for name, catalog_no, description, sku, brand and a submit button' do
    within_form_for Style, noscope: true do
      expect(rendered).to have_field_for :name
      expect(rendered).to have_field_for :catalog_no
      expect(rendered).to have_field_for :description
      expect(rendered).to have_field_for :sku
      expect(rendered).to have_field_for :brand_id
      expect(rendered).to have_field_for :retail
      expect(rendered).to have_selector("[type='submit']")
    end
  end

  it 'description is an Evernote WYSIWYG' do
    expect(rendered).to have_selector("textarea#style_description.summernote")
  end
end
