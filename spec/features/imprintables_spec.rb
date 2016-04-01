require 'spec_helper'
include ApplicationHelper

feature 'Imprintables management', imprintable_spec: true, slow: true do
  given!(:valid_user) { create(:alternate_user) }
  given!(:imprintable) { create(:valid_imprintable) }
  given!(:print_location) { create(:valid_print_location) }

  background(:each) { sign_in_as(valid_user) }

  scenario 'A user can see a list of imprintables' do
    visit root_path
    click_link 'imprintables_list_link'
    expect(page).to have_selector('.box-info')
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

  end

  scenario 'Erroring on imprintable sku + retail combo doesn\'t break anything,\
            card #237 url: https://trello.com/c/KbdIg3Bm', js: true do
    visit edit_imprintable_path imprintable.id
    fill_in 'Sku', with: '333'
    find(:css, 'div.radio#retail_true ins.iCheck-helper', visible: false).click
    click_button 'Update Imprintable'
    expect(page).to have_selector '.modal-content-error', text: 'There was an error saving the imprintable'
  end

  scenario 'A user can create a new imprintable', js: true do
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
    click_link 'Add Compatible Print'
    first('.select-print-location').select(print_location.qualified_name)
    fill_in 'Max imprint width', with: '12'
    fill_in 'Max imprint height', with: '10'

    find_button('Create Imprintable').click

    expect(page).to have_content 'Imprintable was successfully created.'
    expect(current_path).to eq(imprintable_path 2)

    imprintable = Imprintable.find_by special_considerations: 'please don\'t wash this or something'
    expect(imprintable).to_not be_nil
    expect(imprintable.style_name).to eq('Sample Name')
    expect(imprintable.common_name).to eq('Super dooper imprintable')
    expect(imprintable.print_locations).to include print_location
  end

  feature 'Tagging', js: true do
    given!(:imprintable_two) { create(:valid_imprintable) }
    given!(:imprintable_three) { create(:valid_imprintable) }

    scenario 'A user can tag an imprintable', retry: 4, story_692: true do
      visit edit_imprintable_path imprintable.id

      fill_in 'Tags', with: 'cotton'
      find_button('Update Imprintable').click
      ci? ? sleep(2) : wait_for_ajax
      expect(page).to have_content 'Imprintable was successfully updated.'
      expect(current_path).to eq(edit_imprintable_path imprintable.id)
      expect(imprintable.reload.tag_list.include? 'cotton').to be_truthy
    end
  end

  context 'There is a store available', js: true do
    given!(:store) { create(:valid_store) }

    scenario 'A user can utilize sample location token input field', js: true, story_692: true do
      visit edit_imprintable_path imprintable.id

      sleep 1
      find('#imprintable_sample_location_ids').select store.name
      find_button('Update Imprintable').click

      sleep 2 if ci?
      expect(page).to have_content 'Imprintable was successfully updated.'
      expect(current_path).to eq(edit_imprintable_path imprintable.id)
      expect(imprintable.reload.sample_location_ids.include? store.id).to be_truthy
    end
  end

  context 'There is another imprintable' do
    given!(:coordinate) { create(:valid_imprintable) }

    scenario 'A user can utilize coordinate token input field', js: true, story_692: true do
      visit edit_imprintable_path imprintable.id
      wait_for_ajax
      find('#imprintable_coordinate_ids', visible: false).select coordinate.name
      wait_for_ajax
      find_button('Update Imprintable').click

      sleep 2 if ci?
      expect(page).to have_content 'Imprintable was successfully updated.'
      expect(imprintable.reload.coordinate_ids.include? coordinate.id).to be_truthy
    end

    scenario 'Coordinates are reflected symmetrically', no_ci: true, js: true do
      visit edit_imprintable_path imprintable.id

      find('#imprintable_coordinate_ids', visible: false).select coordinate.name
      find_button('Update Imprintable').click

      expect(page).to have_content 'Imprintable was successfully updated.'
      expect(coordinate.reload.coordinate_ids.include? imprintable.id).to be_truthy
    end
  end

  feature 'Imprintable category', js: true do
    scenario 'A user can add an imprintable category' do
      visit edit_imprintable_path imprintable.id

      find_link('Add Imprintable Category').click
      find('[data-placeholder="Select categories"]').select 'Something'
      find_button('Update Imprintable').click

      sleep 2 if ci?
      expect(page).to have_content 'Imprintable was successfully updated.'
      expect(ImprintableCategory.where(imprintable_id: imprintable.id)).to_not be_nil
    end

    context 'there is already an associated imprintable category', js: true do
      given!(:category) { create(:imprintable_category, imprintable_id: imprintable.id) }

      scenario 'A user can delete an imprintable category', story_692: true do
        expect(ImprintableCategory.where(imprintable_id: imprintable.id)).to_not be_nil

        visit edit_imprintable_path imprintable.id

        find(:css, '.js-remove-fields').click
        find_button('Update Imprintable').click

        sleep 2 if ci?
        expect(page).to have_content 'Imprintable was successfully updated.'
        expect(ImprintableCategory.where(imprintable_id: imprintable.id).empty?).to be_truthy
      end
    end
  end

  # CI won't do file upload related stuff
  feature 'Imprintable photos', story_717: true, js: true, no_ci: true do
    let!(:variant) { create(:valid_imprintable_variant) }
    let(:imprintable) { variant.imprintable }

    scenario 'A user can add a photo by uploading a file' do
      visit edit_imprintable_path imprintable

      click_link 'Add Photo'

      within '.imprintable-photo-form' do
        find('.photo-asset-file').set("#{Rails.root}/spec/fixtures/images/macho.png")
        select imprintable.colors.first.name, from: 'Color'
      end

      click_button 'Update Imprintable'
      expect(page).to have_content 'Imprintable was successfully updated.'
      imprintable.reload
      expect(imprintable.imprintable_photos.size).to eq 1
      expect(imprintable.imprintable_photos.first.asset.file).to_not be_nil
    end

    scenario 'A user can add a photo by providing a url' do
      visit edit_imprintable_path imprintable

      click_link 'Add Photo'

      within '.imprintable-photo-form' do
        fill_in 'Upload by URL', with: 'https://www.google.com/images/srpr/logo11w.png'
        select imprintable.colors.first.name, from: 'Color'
      end

      click_button 'Update Imprintable'
      expect(page).to have_content 'Imprintable was successfully updated.'
      imprintable.reload
      expect(imprintable.imprintable_photos.size).to eq 1
      expect(imprintable.imprintable_photos.first.asset.file).to_not be_nil
    end
  end

  scenario 'A user can edit an existing imprintable', js: true, story_692: true  do
    visit edit_imprintable_path imprintable.id

    fill_in 'Special Considerations', with: 'Edited Special Consideration'
    fill_in 'Style Name', with: 'Edited Style Name'
    find_button('Update Imprintable').click

    sleep 2 if ci?
    expect(page).to have_content 'Imprintable was successfully updated.'
    expect(current_path).to eq(edit_imprintable_path imprintable.id)

    expect(imprintable.reload.special_considerations).to eq('Edited Special Consideration')
    expect(imprintable.reload.style_name).to eq('Edited Style Name')

  end

  scenario 'A user can add the imprintable to a group', js: true, story_713: true  do
    group = ImprintableGroup.create!(name: 'The Group')
    imp = create(:valid_imprintable_variant).imprintable

    visit edit_imprintable_path imp.id

    click_link 'Add Imprintable Group'
    select 'The Group', from: 'Group'
    click_button 'Update Imprintable'

    sleep 2 if ci?
    expect(page).to have_content 'Imprintable was successfully updated.'
    expect(current_path).to eq(edit_imprintable_path imp.id)

    expect(imp.reload.imprintable_groups).to include group
  end

  scenario 'A user can delete an existing imprintable', js: true do
    visit imprintables_path
    find("tr#imprintable_#{imprintable.id} a[data-action='destroy']").click
    sleep 2
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
    expect(page).to have_content 'Imprintable was successfully destroyed.'
    expect(Imprintable.where(id: imprintable.id)).to_not exist
    expect(page).not_to have_content "$9.99"
  end

  scenario 'A user can add an imprintable to a quote from an index entry', retry: 3, story_692: true, refactor: true, js: true do
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

    sleep 2
    expect(page).to have_content 'Quote was successfully updated.'
  end

  context 'There are 2 different imprintables', js: true do
    given!(:imprintable_two) { create(:valid_imprintable) }

    scenario 'A user can display the modal show without having multiple shows being rendered at once (card #136)', no_work: true do
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

  feature 'Cannot add text files as photos' do
    scenario 'A user cannot add a text file as an imprintable_photo', js: true do
      visit edit_imprintable_path imprintable.id
      click_link "Add Photo"
      find("input[type='file']").set "#{Rails.root}/spec/fixtures/fba/PackingSlipBadSku.txt"
      click_button "Update Imprintable"
      expect(page).to have_content "Imprintable photos asset file must be proper file format"
    end
  end
end
