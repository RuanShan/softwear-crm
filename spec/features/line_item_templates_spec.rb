require 'spec_helper'

feature 'Line Item Templates', story_494: true do
  given(:user) { create(:user) }
  given!(:template) { create(:line_item_template) }

  context 'as a logged in user,' do
    before(:each) do
      sign_in_as(user)
    end

    scenario 'I can view the list of line item templates from the navigation bar' do
      visit root_path
      click_link 'Configuration'
      click_link 'Line Item Templates'
      expect(page).to have_content template.name
    end

    scenario 'I can create a new line item template' do
      visit line_item_templates_path
      click_link 'New line item template'

      fill_in 'Name', with: 'Huge Loser Upcharge'
      fill_in 'Description', with: 'Give me your lunch money, nerd'
      fill_in 'Url', with: 'http://google.com'
      fill_in 'Unit price', with: 20.00

      click_button 'Create Line Item Template'

      expect(page).to have_content 'successfully created'
      expect(
        LineItemTemplate.where(
          name:        'Huge Loser Upcharge',
          description: 'Give me your lunch money, nerd',
          url:         'http://google.com',
          unit_price:  20.00
        )
      )
        .to exist
    end

    scenario 'I can destroy a line item template' do
      visit line_item_templates_path
      find('a[data-action=destroy]').click
      expect(LineItemTemplate.where(id: template.id)).to_not exist
    end
  end
end
