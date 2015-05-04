require 'spec_helper'

feature 'Imprintable Groups management', story_564: true do
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as(valid_user) }

  scenario 'A user can create an imprintable group' do
    visit imprintable_groups_path
    click_link 'Add a group'
    fill_in 'Name', with: 'stuff'
    click_button 'Create Imprintable Group'
    expect(page).to have_content 'stuff'
    expect(ImprintableGroup.where(name: 'stuff')).to exist
  end
end
