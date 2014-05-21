require 'spec_helper'

describe 'users/index.html.erb', user_spec: true do
  before :each do
    assign(:users, [
      create(:user, 
        firstname: 'first1', lastname: 'last1', 
        email: 'test1@example.com'),
      create(:user, 
        firstname: 'first2', lastname: 'last2',
        email: 'test2@example.com')
    ])
  end

  it 'displays the firstname and lastname of all users' do
    render
    expect(rendered).to have_selector '*', text: 'first1'
    expect(rendered).to have_selector '*', text: 'first2'
  end

  it 'displays the emails of all users' do
    render
    expect(rendered).to have_selector '*', text: 'test1@example.com'
    expect(rendered).to have_selector '*', text: 'test2@example.com'
  end

  it 'has a "new user" button' do
    render
    expect(rendered).to have_button_or_link_to new_user_registration_path
  end
end