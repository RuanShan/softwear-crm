require 'spec_helper'
include ApplicationHelper

feature 'Proof Features', js: true, proof_spec: true, retry: 3 do
  given!(:artwork_request) { create(:valid_artwork_request_with_artwork) }
  given!(:order) { create(:order_with_proofs) }
  given!(:proof) { order.proofs.first }
  given!(:valid_user) { create(:alternate_user) }
  given!(:artwork) { create(:valid_artwork) }

  before(:each) do
    sign_in_as(valid_user)
    allow(order).to receive(:artwork_requests) { [artwork_request] }
    create(:artwork_proof, artwork: artwork, proof: proof)
    allow_any_instance_of(Order).to receive(:artworks) {[artwork]}
  end

  scenario 'A user can view a list of Proofs' do
    visit root_path
    if ci?
      visit edit_order_path(order, anchor: 'proofs')
    else
      unhide_dashboard
      click_link 'Orders'
      click_link 'List'
      find("a[href='/orders/#{order.id}/edit']").click
      find("a[href='#proofs']").click
    end
    expect(page).to have_css('div.proof-list')
    expect(page).to have_css("div#proof-#{proof.id}")
  end

  scenario 'A user can create a Proof', no_ci: true do
    expect {
      visit_edit_order_tab(order, 'proofs')
      click_link "Add Proof"
      fill_in 'proof_approve_by', with: '01/23/1992 8:55 PM'
      find('#proof_approve_by').native.send_keys(:return)
      within("div[data-artwork-id='#{artwork.id}']") do
        find(:css, "div.icheckbox_minimal-grey").click
      end
      click_button 'Create Proof'
      expect(page).to have_text("Proof #")
    }.to change{ Proof.count }.by(1)
  end

  scenario 'A user cannot add a text file mockup to a proof', no_ci: true do
      visit_edit_order_tab(order, 'proofs')
      click_link "Add Proof"
      fill_in 'proof_approve_by', with: '01/23/1992 8:55 PM'
      find('#proof_approve_by').native.send_keys(:return)
      within("div[data-artwork-id='#{artwork.id}']") do
        find(:css, "div.icheckbox_minimal-grey").click
      end
      click_link "Add Mockup"
      find("input[type='file']").set "#{Rails.root}/spec/fixtures/fba/PackingSlipBadSku.txt"
      fill_in "Description", with: "This is a test for doc type mockups"
      click_button 'Create Proof'
      sleep 1
      expect(page).to have_text("Mockups file must be proper file format")
  end 

  scenario 'A user can edit and update a Proof from the Proof List', story_692: true do
    visit_edit_order_tab(order, 'proofs')
    within("#proof-#{proof.id}") do
      click_link 'Edit'
    end
    sleep 1
    fill_in 'proof_approve_by', with: '01/23/2012 8:55 PM'
    sleep 1
    click_button 'Update Proof'
    sleep 1 if ci?
    expect(page).to have_content 'Proof was successfully updated'
    sleep 0.5
    find(:css, 'button.close').click
    expect(page).to have_css("div#proof-#{proof.id}")
    expect(Proof.where(id: proof.id)).to exist
  end

  context 'A proof has been rejected either by the manager or the customer' do
    background { proof.update_column(:state, :customer_rejected) }

    scenario 'A user can delete an Proof from the Proof List' do
      expect {
        visit_edit_order_tab(order, 'proofs')
        within("#proof-#{proof.id}") do
          click_link 'Delete'
        end
        sleep 2
        page.driver.browser.switch_to.alert.accept
        expect(page).to_not have_css("div#proof-#{proof.id}")
      }.to change{ Proof.count }.by(-1)
    end
  end

  context 'State Transitions' do
    context 'as an artist' do
      context 'assuming an order with artwork requests that are assigned and approved' do
        background { order.artwork_requests.each{|x| x.assigned_artist(valid_user) } }

        context "given a proof that is 'not_ready' and the order#artwork_state is 'pending_proofs'" do
          background do
            order.update_attribute(:artwork_state, :pending_proofs)
            proof.update_attribute(:state, :not_ready)
            allow_any_instance_of(Order).to receive(:missing_proofs?) { false }
          end

          scenario 'I can mark all proofs as ready' do
            visit_edit_order_tab(order, 'proofs')
            click_link 'All Proofs Ready for Manager Approval'
            sleep(1.5)
            close_flash_modal
            navigate_to_tab 'Timeline'
            expect(page).to have_text("#{valid_user.full_name} changed order artwork_state"\
                      " from pending_proofs to pending_manager_approval")
            expect(order.proofs.map(&:state)).to eq(["pending_manager_approval"])
            expect(order.reload.artwork_state).to eq("pending_manager_approval")
          end

          scenario 'I can mark an individual proof as ready' do
            visit_edit_order_tab(order, 'proofs')
            within("#proof-#{proof.id}") do
              click_link "Ready For Manager Approval"
            end
            sleep(1.5)
            close_flash_modal
            navigate_to_tab 'Timeline'
            expect(page).to have_text("#{valid_user.full_name} changed proof ##{proof.id} state"\
                      " from not_ready to pending_manager_approval")
            expect(order.proofs.map(&:state)).to eq(["pending_manager_approval"])
            expect(order.reload.artwork_state).to eq("pending_manager_approval")
          end
        end
      end
    end

    context 'as a proofing manager' do
      context "given an order with artwork requests that aren't assigned and approved" do

      end

      context 'given an order with artwork requests that are assigned and approved' do
        given!(:artwork) { create(:valid_artwork, artist_id: valid_user.id) }

        context "given a proof that is 'pending_manager_approval' and the order#artwork_state is 'pending_manager_approval'" do
          background do
            order.update_attribute(:artwork_state, :pending_manager_approval)
            proof.update_attribute(:state, :pending_manager_approval)
          end

          scenario 'I can manager approve all the proofs' do
            visit_edit_order_tab(order, 'proofs')
            click_link 'All Proofs Manager Approved'
            sleep(1.5)
            close_flash_modal
            navigate_to_tab 'Timeline'
            expect(page).to have_text("#{valid_user.full_name} changed order artwork_state"\
                      " from pending_manager_approval to pending_proof_submission")
            expect(order.proofs.map(&:state)).to eq(["pending_customer_submission"])
            expect(order.reload.artwork_state).to eq("pending_proof_submission")
          end

          scenario 'I can mark an individual proof as manager approved' do
            visit_edit_order_tab(order, 'proofs')
            within("#proof-#{proof.id}") do
              click_link 'Manager Approved'
            end
            sleep(1.5)
            close_flash_modal
            navigate_to_tab 'Timeline'
            expect(page).to have_text("#{valid_user.full_name} changed proof ##{proof.id} state"\
                      " from pending_manager_approval to pending_customer_submission")
            expect(order.proofs.map(&:state)).to eq(["pending_customer_submission"])
            expect(order.reload.artwork_state).to eq("pending_proof_submission")
          end
        end

        context "given a proof that is 'pending_customer_submission' and the order#artwork_state is 'pending_proof_submission'" do
          background do
            order.update_attribute(:artwork_state, :pending_proof_submission)
            proof.update_attribute(:state, :pending_customer_submission)
          end

          scenario "I can mark that I've emailed customers all the proofs" do
            visit_edit_order_tab(order, 'proofs')
            click_link 'Emailed Customer All Proofs'
            sleep(1.5)
            close_flash_modal
            navigate_to_tab 'Timeline'
            expect(page).to have_text("#{valid_user.full_name} changed order artwork_state"\
                      " from pending_proof_submission to pending_customer_approval")
            expect(order.proofs.map(&:state)).to eq(["pending_customer_approval"])
            expect(order.reload.artwork_state).to eq("pending_customer_approval")
          end

          scenario 'I can mark an individual proof that it has been e-mailed' do
            visit_edit_order_tab(order, 'proofs')
            within("#proof-#{proof.id}") do
              click_link 'Emailed Customer'
            end
            sleep(1.5)
            close_flash_modal
            navigate_to_tab 'Timeline'
            expect(page).to have_text("#{valid_user.full_name} changed proof ##{proof.id} state"\
                      " from pending_customer_submission to pending_customer_approval")
            expect(order.proofs.map(&:state)).to eq(["pending_customer_approval"])
            expect(order.reload.artwork_state).to eq("pending_customer_approval")
          end
        end

        context "given a proof that is 'pending_customer_approval' and the order#artwork_state is 'pending_customer_approval'" do
          background do
            order.update_attribute(:artwork_state, :pending_customer_approval)
            proof.update_attribute(:state, :pending_customer_approval)
          end

          scenario "I can mark that the customer has approved all emailed proofs" do
            visit_edit_order_tab(order, 'proofs')
            click_link 'Emailed Proofs Approved'
            sleep(1.5)
            close_flash_modal
            navigate_to_tab 'Timeline'
            expect(page).to have_text("#{valid_user.full_name} changed order artwork_state"\
                      " from pending_customer_approval to ready_for_production")
            expect(order.proofs.map(&:state)).to eq(["customer_approved"])
            expect(order.reload.artwork_state).to eq("ready_for_production")
          end

          scenario 'I can mark an individual proof that the customer has approved it' do
            visit_edit_order_tab(order, 'proofs')
            within("#proof-#{proof.id}") do
              click_link 'Customer Approved'
            end
            sleep(1.5)
            close_flash_modal
            navigate_to_tab 'Timeline'
            expect(page).to have_text("#{valid_user.full_name} changed proof ##{proof.id} state"\
                      " from pending_customer_approval to customer_approved")
            expect(order.proofs.map(&:state)).to eq(["customer_approved"])
            expect(order.reload.artwork_state).to eq("ready_for_production")
          end

          scenario 'I can manager reject all the proofs' do
            visit_edit_order_tab(order, 'proofs')
            click_link 'All Proofs Manager Rejected'
            sleep 2
            page.driver.browser.switch_to.alert.accept
            sleep 1.5
            close_flash_modal
            navigate_to_tab 'Timeline'
            expect(page).to have_text("#{valid_user.full_name} changed order artwork_state"\
                      " from pending_customer_approval to pending_proofs")
            expect(order.proofs.map(&:state)).to eq(["manager_rejected"])
            expect(order.reload.artwork_state).to eq("pending_proofs")
          end

          scenario 'I can manager reject a proof on an individual basis' do
            visit_edit_order_tab(order, 'proofs')
            within("#proof-#{proof.id}") do
              click_link 'Manager Rejected'
              sleep 1.5
              page.driver.browser.switch_to.alert.accept
            end
            close_flash_modal
            navigate_to_tab 'Timeline'
            expect(page).to have_text("#{valid_user.full_name} changed proof ##{proof.id} state"\
                      " from pending_customer_approval to manager_rejected")
            expect(order.reload.artwork_state).to eq("pending_proofs")
            expect(proof.reload.state).to eq("manager_rejected")
          end
        end
      end
    end
  end
end
