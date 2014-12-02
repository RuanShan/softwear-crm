require 'spec_helper'

describe 'email_templates/_form.html.erb', email_template_spec: true do
  let!(:email_template) { build_stubbed(:blank_email_template) }

  before(:each) do
    form_for(email_template) { |f| @f = f }
    render partial: 'email_templates/form', locals: { email_template: EmailTemplate.new, f: @f }
  end

  it 'has fields for name, sku, retail and a submit button' do
    within_form_for EmailTemplate, noscope: true do
      expect(rendered).to have_field_for :name
      expect(rendered).to have_field_for :sku
      expect(rendered).to have_field_for :retail
      expect(rendered).to have_selector('button')
    end
  end
end
