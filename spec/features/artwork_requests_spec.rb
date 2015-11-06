require 'spec_helper'
include ApplicationHelper

feature 'Artwork Request Features', js: true, artwork_request_spec: true do
  given!(:artwork_request) { create(:valid_artwork_request) }
  given!(:valid_user) { create(:alternate_user, last_name: 'Lawcock') }
  given!(:order) { artwork_request.jobs.first.order }
  given!(:imprint_method) { create(:valid_imprint_method) }

  background do
    login_as(valid_user)
    imprint_method.ink_colors << create(:ink_color)
    order.imprints.first.imprint_method = imprint_method
    artwork_request.imprints << order.imprints.first unless (artwork_request.imprints - order.imprints).empty?
  end

  scenario 'A user can view a list of artwork requests from the root path via Orders', no_ci: true do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    click_link 'List'
    find("a[href='/orders/#{artwork_request.jobs.first.order.id}/edit']").click
    find("a[href='#artwork']").click
    expect(page).to have_css('h3', text: 'Artwork Requests')
    expect(page).to have_css('div.artwork-request-list')
  end

  scenario 'A user can view a list of artwork requests from the root path via Artwork' do
    visit root_path
    if ci?
      visit artwork_requests_path
    else
      unhide_dashboard
      click_link 'Artwork'
      click_link 'Artwork Requests'
    end
    expect(page).to have_css('h1', text: 'Artwork Requests')
    expect(page).to have_css('table#artwork-request-table')
  end

  scenario 'A user can add an artwork request', add_ar: true, retry: 3, story_692: true, current: true do
    visit new_order_artwork_request_path(artwork_request.jobs.first.order)
    sleep 2 if ci?

    find('#artwork_request_imprint_ids').select order.imprints.first.name

    find('#artwork_request_ink_color_ids_').select(imprint_method.ink_colors.first.name)
    fill_in 'artwork_request_deadline', with: '01/23/1992 8:55 PM'
    fill_in 'Description', with: 'hello'

    click_button 'Create Artwork Request'
    sleep 1
    find(:css, 'button.close').click
    expect(ArtworkRequest.where(description: 'hello')).to exist
  end

  # NOTE this fails in CI for absolutely no reason
  scenario 'A user can edit an artwork request', no_ci: true do
    visit "/orders/#{order.id}/edit#artwork"
    find("a[href='/orders/1/artwork_requests/#{artwork_request.id}/edit']").click
    fill_in 'Description', with: 'edited'
    select 'Normal', from: 'Priority'
    click_button 'Update Artwork Request'
    sleep 1
    find(:css, "button.close").click
    expect(ArtworkRequest.where(description: 'edited')).to exist
  end

  scenario 'A user can delete an artwork request' do
    visit "/orders/#{order.id}/edit#artwork"
    click_link 'Delete'
    expect(page).to have_selector('.modal-content-success')
    find(:css, 'button.close').click
    expect(ArtworkRequest.where(id: artwork_request.id)).to_not exist
    expect(page).to_not have_css("div#artwork-request-#{artwork_request.id}")
    expect(artwork_request.reload.deleted_at).to be_truthy
  end

  scenario 'A user can add ink colors for more than one job sharing the same imprint', story_1005: true do
    visit edit_order_path(order)
    first('.dup-job-button').click
    sleep ci? ? 3 : 1
    expect(order.reload.jobs.size).to eq 2
    visit new_order_artwork_request_path(order)

    first('.select2-selection__rendered').click
    sleep 0.1
    all('.select2-results__option').first.click
    sleep 0.1
    first('.select2-selection__rendered').click
    sleep 0.1
    all('.select2-results__option').last.click
    sleep 0.1

    find('#artwork_request_ink_color_ids_').select(imprint_method.ink_colors.first.name)
    sleep 0.1
    fill_in 'artwork_request_deadline', with: '01/23/1992 8:55 PM'
    fill_in 'Description', with: 'hello'

    click_button 'Create Artwork Request'
    sleep 1
    find(:css, 'button.close').click
    expect(ArtworkRequest.where(description: 'hello')).to exist
    expect(ArtworkRequest.where(description: 'hello').first.ink_colors.first.name)
      .to eq imprint_method.ink_colors.first.name
  end

  scenario 'A user is redirectd to the order path when visiting show', bugfix: true do
    visit artwork_request_path(artwork_request)
    expect(page).to have_content order.name
  end
  
  scenario 'a proofing manager can approve artwork requests that are pending_approval'
  scenario 'a proofigng manager can reject artwork requests that are pending_approval'
  scenario 'an artist can add artwork and have the status become pending_manager_approval'

  context 'search', search: true, no_ci: true do
    background do
      visit artwork_requests_path

      scenario 'user can filter on status', story_940: true do
        find('[id$=artwork_statsu]').select 'Pending'
        click_button 'Search'

        expect(Sunspot.session).to be_a_search_for ArtworkRequest
        expect(Sunspot.session).to have_search_params(:with, :artwork_statsu, 'Pending')
      end

      scenario 'user can filter on deadline before', story_940: true do
        time = 5.days.ago

        find("[id$=deadline][less_than=true]").click
        sleep 0.1
        find("[id$=deadline][less_than=true]").set time.strftime('%m/%d/%Y %I:%M %p')
        find('.artwork-request-search-fulltext').click
        click_button 'Search'

        expect(Sunspot.session).to be_a_search_for ArtworkRequest
        expect(Sunspot.session).to have_search_params(:with) { with(:deadline).less_than(time.to_date) }
      end
    end
  end
end
