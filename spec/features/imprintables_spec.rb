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

#    scenario 'a user can search imprintables and see accurate results', solr: true do
#      visit imprintables_path
#
#      select 'Girls', from: 'filter_sizing_category'
#      fill_in 'js_search', with: 'test'
#      click_button 'Search'
#
#      expect(page).to have_content test_imprintable1.name
#      expect(page).to have_content test_imprintable2.name
#      expect(page).to have_content test_imprintable3.name
#
#      expect(page).to_not have_content noshow_imprintable1.name
#      expect(page).to_not have_content noshow_imprintable2.name
#    end

#    scenario 'a user sees the values from their last search in the search box', solr: true do
#      visit imprintables_path
#
#      select 'Infant', from: 'filter_sizing_category'
#      fill_in 'js_search', with: 'I should be there'
#      click_button 'Search'
#
#      expect(page).to have_content 'Infant'
#      expect(page).to have_selector '*[value="I should be there"]'
#    end
  end

  scenario 'Erroring on imprintable sku + retail combo doesn\'t break anything,\
            card #237 url: https://trello.com/c/KbdIg3Bm', js: true do
    visit edit_imprintable_path imprintable.id
    fill_in 'Sku', with: '333'
    find(:css, 'div.radio#retail_true ins.iCheck-helper', visible: false).click
    click_button 'Update Imprintable'
    expect(page).to have_selector '.modal-content-error', text: 'There was an error saving the imprintable'
  end

  scenario 'A user can create a new imprintable', pending: "I don't know why this isn't working", js: true do
    visit imprintables_path

    click_link('New Imprintable')
    fill_in 'Special Considerations', with: 'please don\'t wash this or something'
    page.find_by_id('imprintable_sizing_category').find("option[value='#{imprintable.sizing_category}']").click
    page.find_by_id('imprintable_brand_id').find("option[value='#{imprintable.brand.id}']").click

    fill_in 'Style Name', with: 'Sample Name'
    fill_in 'Catalog Number', with: '42'
    fill_in 'Style Description', with: 'Description'
    fill_in 'Common Name', with: 'Super dooper imprintable'

    fill_in 'Sku', with: '99'
    fill_in 'Max imprint width', with:  '5.5'
    fill_in 'Max imprint height', with: '5.5'

    find_button('Create Imprintable').click

    expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully created.'
    expect(current_path).to eq(imprintable_path 2)

    imprintable = Imprintable.find_by special_considerations: 'please don\'t wash this or something'
    expect(imprintable).to_not be_nil
    expect(imprintable.style_name).to eq('Sample Name')
    expect(imprintable.common_name).to eq('Super dooper imprintable')
  end

  feature 'Tagging', js: true do
    given!(:imprintable_two) { create(:valid_imprintable) }
    given!(:imprintable_three) { create(:valid_imprintable) }

    scenario 'A user can tag an imprintable', story_692: true do
      visit edit_imprintable_path imprintable.id

      fill_in 'Tags', with: 'cotton'
      find_button('Update Imprintable').click
      wait_for_ajax
      expect(page).to have_content 'Imprintable was successfully updated.'
      expect(current_path).to eq(edit_imprintable_path imprintable.id)
      expect(imprintable.reload.tag_list.include? 'cotton').to be_truthy
    end
  end

  context 'There is a store available', js: true do
    given!(:store) { create(:valid_store) }

    scenario 'A user can utilize sample location token input field', pending: 'The option is clearly there, but it cannot find it', js: true, story_692: true do
      visit edit_imprintable_path imprintable.id

      sleep 1
      find('#imprintable_sample_location_ids').select store.id
      find_button('Update Imprintable').click

      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(current_path).to eq(edit_imprintable_path imprintable.id)
      expect(imprintable.reload.sample_location_ids.include? store.id).to be_truthy
    end
  end

  context 'There is another imprintable' do
    given!(:coordinate) { create(:valid_imprintable) }

    scenario 'A user can utilize coordinate token input field', js: true, story_692: true, pending: "select2" do
      visit edit_imprintable_path imprintable.id
      wait_for_ajax
      find('Coordinate Imprintables', visible: false).select coordinate.name 
      select_from_chosen(coordinate.name, from: 'Coordinate Imprintables')
      wait_for_ajax
      find_button('Update Imprintable').click

      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(imprintable.reload.coordinate_ids.include? coordinate.id).to be_truthy
    end

    scenario 'Coordinates are reflected symmetrically', js: true, pending: 'select from chosen' do
      visit edit_imprintable_path imprintable.id.

      select_from_chosen(coordinate.name, from: 'Coordinate Imprintables')
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

    context 'there is already an associated imprintable category', js: true, wip: true do
      given!(:category) { create(:imprintable_category, imprintable_id: imprintable.id) }

      scenario 'A user can delete an imprintable category', story_692: true do
        expect(ImprintableCategory.where(imprintable_id: imprintable.id)).to_not be_nil

        visit edit_imprintable_path imprintable.id

        find(:css, '.js-remove-fields').click
        find_button('Update Imprintable').click

        expect(page).to have_content 'Imprintable was successfully updated.'
        expect(ImprintableCategory.where(imprintable_id: imprintable.id).empty?).to be_truthy
      end
    end
  end

  context 'There is an imprint method' do
    given!(:imprint_method) { create(:valid_imprint_method) }

    scenario 'A user can utilize compatible imprint methods token input field', js: true, story_692: true do
      visit edit_imprintable_path imprintable.id

      sleep 2
      find('#imprintable_compatible_imprint_method_ids').select imprint_method.id
      find_button('Update Imprintable').click

      expect(page).to have_content 'Imprintable was successfully updated.'
      expect(imprintable.reload.compatible_imprint_method_ids.include? imprint_method.id).to be_truthy
    end
  end

  scenario 'A user can edit an existing imprintable', js: true, story_692: true  do
    visit edit_imprintable_path imprintable.id

    fill_in 'Special Considerations', with: 'Edited Special Consideration'
    fill_in 'Style Name', with: 'Edited Style Name'
    find_button('Update Imprintable').click

    expect(page).to have_content 'Imprintable was successfully updated.'
    expect(current_path).to eq(edit_imprintable_path imprintable.id)

    expect(imprintable.reload.special_considerations).to eq('Edited Special Consideration')
    expect(imprintable.reload.style_name).to eq('Edited Style Name')

  end

  scenario 'A user can delete an existing imprintable', js: true, story_692: true do
    visit imprintables_path
    find("tr#imprintable_#{imprintable.id} a[data-action='destroy']").click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(page).to have_content 'Imprintable was successfully destroyed.'
    expect(current_path).to eq(imprintables_path)
   # expect(imprintable.reload.destroyed? ).to be_truthy
    expect(page).not_to have_content "$9.99"
  end

  scenario 'A user can click a link to open the modal price popup', js: true, pending: 'NO MORE PRICING TABLE' do
    visit imprintables_path

    find_link("pricing_button_#{imprintable.id}").click
    expect(page).to have_selector '#contentModal.modal.fade.in'
  end

  scenario 'A user can add an imprintable to a quote from an index entry', story_692: true, refactor: true, js: true do
    quote = create(:valid_quote)
    job   = create(:job, jobbable: quote)

    imprintable.imprintable_variants << create(:valid_imprintable_variant)

    allow(Quote).to receive(:search)
      .and_return double('Search', results: [quote])

    visit imprintables_path
    find_link("add-#{imprintable.id}-to-quote").click

    sleep 0.5

    within '#quote-search-form' do
      find('#quote-search-box').set('A quote')
      click_button 'Search'
      sleep 0.5
    end

    visit edit_quote_path(quote, add_imprintable: imprintable.id, anchor: 'line_items')

    sleep 1
    select quote.jobs.first.name, from: 'Group'
    select 'Best', from: 'Tier'
    fill_in 'Quantity', with: '3'
    fill_in 'Decoration price', with: '25.99'

    click_button 'Add Imprintable(s)'

    expect(page).to have_content 'Quote was successfully updated.'
  end

#  scenario 'A user can navigate to all tabs of the modal show menu (card #133)', js: true, story_692: true  do
#    visit imprintables_path
#
#    find(:css, "#imprintable_#{imprintable.id} td a.imprintable_modal_link").click
#    expect(page).to have_selector "#basic_info_#{imprintable.id}.active"
#    expect(page).to have_selector '.nav.nav-tabs.nav-justified li:nth-child(1).active'
#
#    find(:css, '.nav.nav-tabs.nav-justified li:nth-child(2)').click
#    expect(page).to have_selector "#size_color_availability_#{imprintable.id}.active"
#    expect(page).to have_selector '.nav.nav-tabs.nav-justified li:nth-child(2).active'
#
#    find(:css, '.nav.nav-tabs.nav-justified li:nth-child(3)').click
#    expect(page).to have_selector "#imprint_details_#{imprintable.id}.active"
#    expect(page).to have_selector '.nav.nav-tabs.nav-justified li:nth-child(3).active'
#
#    find(:css, '.nav.nav-tabs.nav-justified li:nth-child(4)').click
#    expect(page).to have_selector "#supplier_information_#{imprintable.id}.active"
#    expect(page).to have_selector '.nav.nav-tabs.nav-justified li:nth-child(4).active'
#
#    find(:css, '.nav.nav-tabs.nav-justified li:nth-child(1)').click
#    expect(page).to have_selector "#basic_info_#{imprintable.id}.active"
#    expect(page).to have_selector '.nav.nav-tabs.nav-justified li:nth-child(1).active'
#  end

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

  context 'Discontinuation', story_595: :true do

    scenario 'A user can discontinue and reinstate an imprintable' do
      visit imprintables_path
      click_button('Discontinue') 
     # page.driver.browser.switch_to.alert.accept
      visit imprintables_path
      imprintable.reload
      expect(imprintable).to be_discontinued
      expect(page).to have_content('Reinstate')
      expect(page).to have_css('.discontinued-imprintable')
      expect(page).to have_css('.discontinued-imprintable s')

      visit imprintables_path
      click_button('Reinstate') 
     # page.driver.browser.switch_to.alert.accept
      visit imprintables_path
      imprintable.reload
      expect(imprintable).not_to be_discontinued
      expect(page).to have_content('Discontinue')
      expect(page).not_to have_css('.discontinued-imprintable')
      expect(page).not_to have_css('.discontinued-imprintable s')
    end
  end

end
