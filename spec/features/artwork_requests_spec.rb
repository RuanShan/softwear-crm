require 'spec_helper'
include ApplicationHelper


feature 'Artwork Request Features', js: true, artwork_request_spec: true do
  given!(:artwork_request) { create(:valid_artwork_request) }
  given!(:valid_user) { create(:alternate_user, last_name: 'Lawcock') }
  given!(:order) { artwork_request.jobs.first.order }
  given!(:imprint_method) { create(:valid_imprint_method) }

  background do
    sign_in_as(valid_user)
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


  # NOTE this fails in CI for absolutely no reason
  scenario 'A user can edit an artwork request', no_ci: true do
    visit "/orders/#{order.id}/edit#artwork"
    find("a[href='/orders/#{order.id}/artwork_requests/#{artwork_request.id}/edit']").click
    fill_in 'Description', with: 'edited'
    select 'Normal', from: 'Priority'
    click_button 'Update Artwork request'
    sleep 1
    find(:css, "button.close").click
    expect(ArtworkRequest.where(description: 'edited')).to exist
  end

  scenario 'A user can add a text file attachment to an artwork request', no_ci: true do
    visit "/orders/#{order.id}/edit#artwork"
    find("a[href='/orders/#{order.id}/artwork_requests/#{artwork_request.id}/edit']").click
    click_link 'Add Attachment'
    sleep 15
    find("input[type='file']").set "#{Rails.root}/spec/fixtures/fba/PackingSlipBadSku.txt"
    find("textarea[name^='artwork_request[assets_attributes]']").set("Doc type")
    click_button 'Update Artwork request'
    sleep 1
    find(:css, "button.close").click
    expect(Asset.where(description: 'Doc type')).to exist
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

    click_button 'Create Artwork request'
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

  context 'State Transitions', retry: 3 do
    context 'as a salesperson' do
      scenario 'A user can add an artwork request, and its initial status is unassigned', add_ar: true, story_692: true do
        PublicActivity.with_tracking do
          visit new_order_artwork_request_path(artwork_request.jobs.first.order)
          sleep 1.5
          find('#artwork_request_imprint_ids').select order.imprints.first.name
          find('#artwork_request_ink_color_ids_').select(imprint_method.ink_colors.first.name)
          fill_in 'artwork_request_deadline', with: '01/23/1992 8:55 PM'
          fill_in 'Description', with: 'hello'
          click_button 'Create Artwork request'
          sleep 1.5
          find(:css, 'button.close').click
          expect(ArtworkRequest.where(description: 'hello')).to exist
          expect(ArtworkRequest.find_by(description: 'hello').state).to eq("unassigned")
          navigate_to_tab 'Timeline'
          expect(page).to have_text("#{valid_user.full_name} added Artwork request")
        end
      end

      context 'an artwork request exists for every imprint' do
        scenario "I can mark an order as 'Artwork Requests Complete'" do
          PublicActivity.with_tracking do
            visit edit_order_path(order)
            navigate_to_tab 'Artwork'
            click_link("Mark Artwork Requests Complete")
            sleep 1.5
            close_flash_modal
            navigate_to_tab 'Timeline'
            expect(order.reload.artwork_state).to eq('pending_artwork_and_proofs')
            expect(page).to have_text("#{valid_user.full_name} changed order artwork_state"\
                      " from pending_artwork_requests to pending_artwork_and_proofs")
          end
        end
      end

      context 'an imprint is missing an artwork request' do
        background{ order.artwork_requests.first.destroy }

        scenario "I see a warning that includes the imprint that's missing an artwork request" do
          visit edit_order_path(order)
          navigate_to_tab 'Artwork'
          expect(page).to have_no_link("Mark Artwork Requests Complete")
          expect(page).to have_css ".alert-danger", text: "This order is missing artwork requests."\
                                    " Artwork can not proceed until all imprints have an artwork"\
                                    " request associated with them."
        end
      end

      context 'An artwork request is rejected' do
        background{ order.artwork_requests.each{|ar| ar.update_column(:state, :artwork_request_rejected) } }

        scenario 'A salesperson can revise it, and mark it as revised' do
          visit edit_order_path(order)
          navigate_to_tab 'Artwork'
          click_link 'Mark Artwork Request Revised'
          close_flash_modal
          sleep 1.5
          expect(artwork_request.reload.state).to_not eq('artwork_request_rejected')
          expect(order.reload.artwork_state).to eq('pending_artwork_and_proofs')
        end
      end
    end

    context 'as an artist' do
      context 'given an artwork request' do
        context 'every artwork request has artwork attached to it' do

          let(:artwork) { create(:valid_artwork) }

          background do
            order.update_column(:artwork_state, 'pending_artwork_and_proofs')
            order.artwork_requests.each do |ar|
              ar.assigned_artist(valid_user)
              ar.artworks << artwork
              ar.save
            end
          end

          context 'but artwork request artist is not assigned'  do
            background{ order.artwork_requests.each{|ar| ar.unassigned_artist} }

            scenario 'I am notified that I cannot mark artwork complete without artwork being assigned' do
              visit edit_order_path(order)
              navigate_to_tab 'Artwork'
              expect(page).to have_no_link("Mark Artwork Complete")
              expect(page).to have_css ".alert-danger", text: "This order has unassigned artwork requests."
            end
          end

          context ' I have not added proofs' do
            scenario 'I can mark the order as Artwork Complete transitioning it to pending_proofs' do
              PublicActivity.with_tracking do
                visit edit_order_path(order)
                navigate_to_tab 'Artwork'
                click_link 'Mark Artwork Complete'
                close_flash_modal
                navigate_to_tab 'Timeline'
                expect(order.reload.artwork_state).to eq('pending_proofs')
                expect(order.artwork_requests.map(&:state).uniq).to eq(['pending_manager_approval'])
                expect(page).to have_text("#{valid_user.full_name} changed order artwork_state"\
                          " from pending_artwork_and_proofs to pending_proofs")
              end
            end
          end

          context 'every artwork request has a proof associated with it' do

            given!(:proof) { create(:valid_proof, order: order, artworks: [artwork]) }
            given!(:artwork_proof) { create(:artwork_proof, artwork: artwork, proof: proof) }

            scenario 'I can mark the order as Artwork Complete transitioning it to pending_manager_approval' do
              PublicActivity.with_tracking do
                visit_edit_order_tab(order, 'artwork')
                click_link("Mark Artwork Complete")
                close_flash_modal
                navigate_to_tab 'Timeline'
                expect(order.reload.artwork_state).to eq('pending_manager_approval')
                expect(order.artwork_requests.map(&:state).uniq).to eq(['pending_manager_approval'])
                expect(page).to have_text("#{valid_user.full_name} changed order artwork_state"\
                          " from pending_artwork_and_proofs to pending_manager_approval")
              end
            end
          end
        end

      end
    end

    context 'as a proofing manager' do
      context 'given an artwork request' do
        scenario 'I can reject the artwork request' do
          visit_edit_order_tab(order, 'artwork')
          sleep 1.5
          within("#artwork-request-#{artwork_request.id}") do
            click_link "Reject Artwork Request"
            fill_in "details", with: "This is a reason"
            find('.reject-button').click
          end
          sleep 1.5
          close_flash_modal
          navigate_to_tab 'Timeline'
          expect(artwork_request.reload.state).to eq("artwork_request_rejected")
          expect(order.reload.artwork_state).to eq("pending_artwork_requests")
          expect(page).to have_text("to artwork_request_rejected via transition reject_artwork_request")
          expect(page).to have_text("This is a reason")
          expect(order.warnings.map(&:source)).to include("Bad Artwork Request")
          # rejected artwork requests show up on the salesperson's homepage
        end

        scenario 'I can assign the artwork request to an artist'

        scenario 'I can assign artwork to it by changing the artist in the edit form' do
          visit edit_order_artwork_request_path(order, artwork_request)
          select(valid_user.full_name, from: 'Artist')
          click_button "Update Artwork request"
          sleep(1.5)
          expect(artwork_request.reload.state).to eq('pending_artwork')
        end

        context 'and the artwork_request is pending_approval or approved'  do
          let(:artwork) { create(:valid_artwork) }

          background do
            order.update_column(:artwork_state, :pending_manager_approval)
            order.artwork_requests.each do |ar|
              ar.update_attribute(:artist_id, valid_user.id)
              ar.update_attribute(:state, 'pending_manager_approval')
              ar.artworks << artwork
              ar.save
            end
          end

          scenario 'I can reject the artwork for a request' do
            visit_edit_order_tab(order, 'artwork')
            within("#artwork-request-#{artwork_request.id}") do
              click_link "Reject Artwork"
              fill_in "details", with: "This is another reason"
              find('.reject-button').click
            end
            sleep 1.5
            close_flash_modal
            navigate_to_tab 'Timeline'
            expect(artwork_request.reload.state).to eq("artwork_rejected")
            expect(order.reload.artwork_state).to eq("pending_artwork_and_proofs")
            expect(page).to have_text("to artwork_rejected via transition reject_artwork")
            expect(page).to have_text("This is another reason")
          end
        end
      end
    end

  end

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
