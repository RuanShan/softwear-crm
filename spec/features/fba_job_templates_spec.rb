require 'spec_helper'

feature 'FBA Job Tempaltes management', js: true do
  given!(:print_location_1) { create(:valid_print_location) }
  given!(:print_location_2) { create(:valid_print_location) }

  given!(:imprint_method_1) { print_location_1.imprint_method }
  given!(:imprint_method_2) { print_location_2.imprint_method }
  given(:fba_job_template) { create(:fba_job_template_with_imprint) }

  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as(valid_user) }

  scenario 'A user can create a new FBA Job Template', new: true do
    visit new_fba_job_template_path
    fill_in 'Name', with: 'cool new template'

    click_link 'Add Imprint'
    sleep 1
    find('select[name=imprint_method]').select imprint_method_2.name
    fill_in 'Description', with: 'An imprint!'

    click_button "Create FBA Job Template"

    expect(page).to have_content 'successfully created'
    new_template = FbaJobTemplate.where(name: 'cool new template')
    expect(new_template).to exist
    expect(new_template.first.imprints).to exist
    expect(new_template.first.imprints.first.description).to eq 'An imprint!'
    expect(new_template.first.imprints.first.print_location_id).to eq imprint_method_2.print_locations.first.id
  end

  scenario 'A user can edit an existing FBA job tamplate', edit: true do
    visit edit_fba_job_template_path(fba_job_template)
    fill_in 'Name', with: 'cool new name'

    find('select[name=imprint_method]').select imprint_method_2.name
    fill_in 'Description', with: 'New imprint stuff'

    click_button "Update FBA Job Template"

    expect(page).to have_content 'successfully updated'
    new_template = FbaJobTemplate.where(name: 'cool new name')
    expect(new_template).to exist
    expect(new_template.first.imprints).to exist
    expect(new_template.first.imprints.first.description).to eq 'New imprint stuff'
    expect(new_template.first.imprints.first.print_location_id).to eq imprint_method_2.print_locations.first.id
  end
end
