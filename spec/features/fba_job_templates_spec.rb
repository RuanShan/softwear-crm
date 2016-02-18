require 'spec_helper'

feature 'FBA Job Tempaltes management', js: true do
  given!(:print_location_1) { create(:valid_print_location) }
  given!(:print_location_2) { create(:valid_print_location) }

  given!(:imprint_method_1) { print_location_1.imprint_method }
  given!(:imprint_method_2) { print_location_2.imprint_method }
  given(:fba_job_template) { create(:fba_job_template_with_imprint) }
  given(:mockup_file_path) { "#{Rails.root}/spec/fixtures/images/test-mockup.png" }

  given!(:valid_user) { create(:alternate_user) }
  background(:each) { sign_in_as(valid_user) }

  before(:each) do
    Capybara.ignore_hidden_elements = false
  end

  after(:each) do
    Capybara.ignore_hidden_elements = true
  end

  scenario 'A user can create a new FBA Job Template', retry: (3 if ci?), new: true do
    visit new_fba_job_template_path
    fill_in 'Name', with: 'cool new template'

    click_link 'Add Imprint'
    sleep 1
    find('select[name=imprint_method]').select imprint_method_2.name
    fill_in 'Description', with: 'An imprint!'

    find('input[type=file]').set mockup_file_path

    click_button "Create FBA Job Template"
    sleep 10

    new_template = FbaJobTemplate.where(name: 'cool new template')
    expect(new_template).to exist
    expect(new_template.first.fba_imprint_templates).to exist
    expect(new_template.first.fba_imprint_templates.first.description).to eq 'An imprint!'
    expect(new_template.first.fba_imprint_templates.first.print_location_id).to eq imprint_method_2.print_locations.first.id
  end

  scenario 'A user can edit an existing FBA job tamplate', edit: true do
    visit edit_fba_job_template_path(fba_job_template)
    fill_in 'Name', with: 'cool new name'

    find('select[name=imprint_method]').select imprint_method_2.name
    fill_in 'Description', with: 'New imprint stuff'

    click_button "Update FBA Job Template"
    sleep 2

    new_template = FbaJobTemplate.where(name: 'cool new name')
    expect(new_template).to exist
    expect(new_template.first.fba_imprint_templates).to exist
    expect(new_template.first.fba_imprint_templates.first.description).to eq 'New imprint stuff'
    expect(new_template.first.fba_imprint_templates.first.print_location_id).to eq imprint_method_2.print_locations.first.id
  end

  context 'with artwork present', artwork: true do
    given!(:artwork_1) { create(:valid_artwork, name: 'Le first artwork') }
    given!(:artwork_2) { create(:valid_artwork, name: 'Le seconde artwork') }

    scenario 'A user can select multiple artwork for an FBA job template', no_ci: true do
      visit new_fba_job_template_path
      fill_in 'Name', with: 'cool new template'
      find('input[type=file]').set mockup_file_path

      click_link 'Add Imprint'
      sleep 1
      find('select[name=imprint_method]').select imprint_method_2.name
      fill_in 'Description', with: 'An imprint!'
      click_link 'Select Artwork'
      sleep 2
      find('.select-artwork-entry', text: artwork_1.name).click
      sleep 2
      expect(page).to have_css "img[src='#{artwork_1.preview.file.url(:thumb)}']"

      click_link 'Add Imprint'
      sleep 1
      within all('.imprint-entry').last do
        find('select[name=imprint_method]').select imprint_method_1.name
        fill_in 'Description', with: 'Another imprint!'
        click_link 'Select Artwork'
        sleep 2
      end
      find('.select-artwork-entry', text: artwork_2.name).click
      sleep 2
      expect(page).to have_css "img[src='#{artwork_2.preview.file.url(:thumb)}']"

      click_button "Create FBA Job Template"
      sleep 7

      new_template = FbaJobTemplate.where(name: 'cool new template')
      expect(new_template).to exist
      expect(new_template.first.fba_imprint_templates).to exist
      expect(new_template.first.fba_imprint_templates.first.description).to eq 'An imprint!'
      expect(new_template.first.fba_imprint_templates.first.artwork_id).to eq artwork_1.id

      expect(new_template.first.fba_imprint_templates.last.description).to eq 'Another imprint!'
      expect(new_template.first.fba_imprint_templates.last.artwork_id).to eq artwork_2.id
    end
  end
end
