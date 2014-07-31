require 'spec_helper'

describe 'users/new.html.erb', user_spec: true do
  before :each do
    assign(:user, create(:user))
    render
  end

  it 'should have fields for email and first/last names' do
    within_form_for User do
      expect(rendered).to have_field_for :email
      expect(rendered).to have_field_for :first_name
      expect(rendered).to have_field_for :last_name
    end
  end

  it 'should not have password field' do
    within_form_for User do
      expect(rendered).to_not have_field_for :password
    end
  end
end