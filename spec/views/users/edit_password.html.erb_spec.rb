require 'spec_helper'

describe 'users/edit_password.html.erb', user_spec: true do
  let!(:user) { create(:user) }
  before(:each) do
    assign(:current_user, user)
  end

  it 'has fields necessary to change passwords' do
    render
    within_form_for User do
      expect(rendered).to have_field_for :password
      expect(rendered).to have_field_for :password_confirmation
      expect(rendered).to have_field_for :current_password
    end
  end

  it 'does not have the email field' do
    render
    within_form_for User do
      expect(rendered).to_not have_field_for :email
    end
  end
end