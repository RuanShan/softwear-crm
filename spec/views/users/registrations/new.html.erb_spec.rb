require 'spec_helper'

describe 'users/registrations/new.html.erb', user_spec: true do
  before :each do
    render 'users/registrations/new', locals: { resource: User.new, resource_name: 'user' }
  end

  it 'should have fields for email and firat/last names' do
    within_form_for User do
      expect(rendered).to have_field_for :email
      expect(rendered).to have_field_for :firstname
      expect(rendered).to have_field_for :lastname
    end
  end

  it 'should not have password field' do
    within_form_for do
      expect(rendered).to_not have_field_for :password
    end
  end
end