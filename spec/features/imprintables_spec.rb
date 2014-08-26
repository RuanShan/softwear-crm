require 'spec_helper'
include ApplicationHelper

feature 'Imprintables management', imprintable_spec: true, slow: true do
  given!(:valid_user) { create(:alternate_user) }
  given!(:imprintable) { create(:valid_imprintable) }

  background(:each) { login_as(valid_user) }

  scenario 'A user can see a list of imprintables' do
    visit root_path
    click_link 'imprintables_list_link'
    expect(page).to have_selector('.box-info')
    expect(current_path).to eq(imprintables_path)
  end

  feature 'search', search_spec: true do
    given!(:test_imprintable1) do
      create(:valid_imprintable,
              sizing_category: 'Girls',
              main_supplier: 'main supplier test')
    end

    given!(:test_imprintable2) do
      create(:valid_imprintable,
              sizing_category: 'Girls',
              main_supplier: 'test main supplier')
    end

    given!(:test_imprintable3) do
      create(:valid_imprintable,
              sizing_category: 'Girls',
              main_supplier: 'test main supplier')
    end

    given!(:noshow_imprintable1) do
      create(:valid_imprintable,
              sizing_category: 'Adult Unisex',
              main_supplier: 'test main supplier')
    end

    given!(:noshow_imprintable2) do
      create(:valid_imprintable,
              sizing_category: 'Girls',
              main_supplier: 'other supplier')
    end

    scenario 'a user can search imprintables and see accurate results', solr: true do
      visit imprintables_path

      select 'Girls', from: 'filter_sizing_category'
      fill_in 'imprintables_search', with: 'test'
      click_button 'Search'

      expect(page).to have_content test_imprintable1.name
      expect(page).to have_content test_imprintable2.name
      expect(page).to have_content test_imprintable3.name

      expect(page).to_not have_content noshow_imprintable1.name
      expect(page).to_not have_content noshow_imprintable2.name
    end

    scenario 'a user sees the values from their last search in the search box', solr: true do
      visit imprintables_path

      select 'Infant', from: 'filter_sizing_category'
      fill_in 'imprintables_search', with: 'I should be there'
      click_button 'Search'

      expect(page).to have_content 'Infant'
      expect(page).to have_selector '*[value="I should be there"]'
    end
  end

  scenario 'A user can create a new imprintable', js: true do
    visit imprintables_path

    click_link('Add an Imprintable')
    fill_in 'Special Considerations', with: 'Special Consideration'
    page.find_by_id('imprintable_sizing_category').find("option[value='#{imprintable.sizing_category}']").click
    page.find_by_id('imprintable_brand_id').find("option[value='#{imprintable.brand.id}']").click

    fill_in 'Style name', with: 'Sample Name'
    fill_in 'Style catalog no', with: '42'
    fill_in_summernote('#imprintable_style_description', with: 'Description')

    fill_in 'Sku', with: '99'
    fill_in 'Max imprint width', with:  '5.5'
    fill_in 'Max imprint height', with: '5.5'

    find_button('Create Imprintable').click

    expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully created.'
    expect(current_path).to eq(imprintable_path 2)

    expect(Imprintable.find_by special_considerations: 'Special Consideration').to_not be_nil
    expect(Imprintable.find_by style_name: 'Sample Name').to_not be_nil
  end

  feature 'Tagging', js: true do
    given!(:imprintable_two) { create(:valid_imprintable) }
    given!(:imprintable_three) { create(:valid_imprintable) }
    
    scenario 'A user can tag an imprintable' do
      visit edit_imprintable_path imprintable.id

      fill_in 'Tags', with: 'cotton'
      find_button('Update Imprintable').click

      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(current_path).to eq(edit_imprintable_path imprintable.id)
      expect(imprintable.reload.tag_list.include? 'cotton').to be_truthy
    end
  end

  context 'There is a store available', js: true do
    given!(:store) { create(:valid_store) }
    
    scenario 'A user can utilize sample location token input field', js: true do
      visit edit_imprintable_path imprintable.id

      select_from_chosen(store.name, from: 'Sample Locations')
      find_button('Update Imprintable').click

      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(current_path).to eq(edit_imprintable_path imprintable.id)
      expect(imprintable.reload.sample_location_ids.include? store.id).to be_truthy
    end
  end

  context 'There is another imprintable' do
    given!(:coordinate) { create(:valid_imprintable) }
    
    scenario 'A user can utilize coordinate token input field', js: true do
      visit edit_imprintable_path imprintable.id

      select_from_chosen(coordinate.name, from: 'Coordinates')
      find_button('Update Imprintable').click

      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(imprintable.reload.coordinate_ids.include? coordinate.id).to be_truthy
    end

    scenario 'Coordinates are reflected symmetrically', js: true, pending: 'select from chosen' do
      visit edit_imprintable_path imprintable.id.

      select_from_chosen(coordinate.name, from: 'Coordinates')
      find_button('Update Imprintable').click

      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(coordinate.reload.coordinate_ids.include? imprintable.id).to be_truthy
    end
  end

  feature 'Imprintable category', js: true do
    scenario 'A user can add an imprintable category', pending: 'Can\'t figure out how to select from chosen here' do
      visit edit_imprintable_path imprintable.id

      find_link('Add Imprintable Category').click
      select_from_chosen('Something', from: 'imprintable_categories')
      find_button('Update Imprintable').click

      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(ImprintableCategory.where(imprintable_id: imprintable.id)).to_not be_nil
    end

    context 'there is already an associated imprintable category' do
      given!(:category) { create(:imprintable_category, imprintable_id: imprintable.id) }

      scenario 'A user can delete an imprintable category' do
        expect(ImprintableCategory.where(imprintable_id: imprintable.id)).to_not be_nil

        visit edit_imprintable_path imprintable.id

        find(:css, '.js-remove-fields').click
        find_button('Update Imprintable').click

        expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
        expect(ImprintableCategory.where(imprintable_id: imprintable.id).empty?).to be_truthy
      end
    end
  end

  context 'There is an imprint method' do
    given!(:imprint_method) { create(:valid_imprint_method) }
    
    scenario 'A user can utilize compatible imprint methods token input field', js: true do
      visit edit_imprintable_path imprintable.id

      select_from_chosen(imprint_method.name, from: 'Compatible Imprint Methods')
      find_button('Update Imprintable').click

      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(imprintable.reload.compatible_imprint_method_ids.include? imprint_method.id).to be_truthy
    end
  end

  scenario 'A user can edit an existing imprintable', js: true  do
    visit edit_imprintable_path imprintable.id

    fill_in 'Special Considerations', with: 'Edited Special Consideration'
    fill_in 'Style name', with: 'Edited Style Name'
    find_button('Update Imprintable').click

    expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
    expect(current_path).to eq(edit_imprintable_path imprintable.id)

    expect(imprintable.reload.special_considerations).to eq('Edited Special Consideration')
    expect(imprintable.reload.style_name).to eq('Edited Style Name')

  end

  scenario 'A user can delete an existing imprintable', js: true do
    visit imprintables_path

    find("tr#imprintable_#{imprintable.id} a[data-action='destroy']").click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax

    expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully destroyed.'
    expect(current_path).to eq(imprintables_path)
    expect(imprintable.reload.destroyed? ).to be_truthy
  end

  scenario 'A user can click a link to open the modal price popup', js: true do
    visit imprintables_path

    find_link("pricing_button_#{imprintable.id}").click
    expect(page).to have_selector '#contentModal.modal.fade.in'
  end
  
  scenario 'A user can navigate to all tabs of the modal show menu (card #133)', js: true  do
    visit imprintables_path

    find(:css, "#imprintable_#{imprintable.id} td a.imprintable_modal_link").click
    expect(page).to have_selector "#basic_info_#{imprintable.id}.active"
    expect(page).to have_selector '.nav.nav-tabs.nav-justified li:nth-child(1).active'

    find(:css, '.nav.nav-tabs.nav-justified li:nth-child(2)').click
    expect(page).to have_selector "#size_color_availability_#{imprintable.id}.active"
    expect(page).to have_selector '.nav.nav-tabs.nav-justified li:nth-child(2).active'

    find(:css, '.nav.nav-tabs.nav-justified li:nth-child(3)').click
    expect(page).to have_selector "#imprint_details_#{imprintable.id}.active"
    expect(page).to have_selector '.nav.nav-tabs.nav-justified li:nth-child(3).active'

    find(:css, '.nav.nav-tabs.nav-justified li:nth-child(4)').click
    expect(page).to have_selector "#supplier_information_#{imprintable.id}.active"
    expect(page).to have_selector '.nav.nav-tabs.nav-justified li:nth-child(4).active'

    find(:css, '.nav.nav-tabs.nav-justified li:nth-child(1)').click
    expect(page).to have_selector "#basic_info_#{imprintable.id}.active"
    expect(page).to have_selector '.nav.nav-tabs.nav-justified li:nth-child(1).active'
  end

  context 'There are 2 different imprintables', js: true do
    given!(:imprintable_two) { create(:valid_imprintable) }
    
    scenario 'A user can display the modal show without having multiple shows being rendered at once (card #136)' do
      visit imprintables_path

      expect(find('#contentModal div.modal-body', visible: false).all('*').size).to eq(0)
      expect(find('#contentModal div.modal-body', visible: false).text).to eq('')

      find(:css, "#imprintable_#{imprintable_two.id} td a.imprintable_modal_link").click
      expect(find('#contentModal div.modal-body').all('*').size).to_not eq(0)
      expect(find('#contentModal div.modal-body').text).to_not eq ('')
    end
  end
end
