require 'spec_helper'

feature 'Imprintable Groups management' do
  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as(valid_user) }

  scenario 'A user can create an imprintable group', story_564: true do
    visit imprintable_groups_path
    click_link 'Add a group'
    fill_in 'Name', with: 'stuff'
    click_button 'Create Imprintable Group'
    expect(page).to have_content 'stuff'
    expect(ImprintableGroup.where(name: 'stuff')).to exist
  end

  context 'given some groups exist', js: true do
    given!(:group_1) { create(:imprintable_group_with_imprintables, name: 'Group Number One') }
    given!(:group_2) { create(:imprintable_group_with_imprintables, name: 'Group Number Two') }
    given!(:group_3) { create(:imprintable_group_with_imprintables, name: 'Le Third Groupe') }

    scenario 'A user can fuzzy filter imprintable groups by name', story_955: true do
      visit imprintable_groups_path
      find('#filter_groups').set 'gro num'

      expect(page).to have_content group_1.name
      expect(page).to have_content group_2.name
      expect(page).to_not have_content group_3.name
    end

    scenario 'A user can click on a group to view the imprintables inside', story_955: true do
      visit imprintable_groups_path

      find('td', text: group_1.name).click

      group_1.imprintables.each do |imprintable|
        expect(page).to have_content imprintable.name
        expect(page).to have_content imprintable.base_price.round(2).to_s
      end
    end
  end
end
