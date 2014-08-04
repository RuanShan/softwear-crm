require 'spec_helper'
include ApplicationHelper

feature 'Proof Features', proof_spec: true do
  given!(:valid_user) { create(:alternate_user) }
  given!(:artwork_request) { create(:valid_artwork_request_with_artwork) }
  given!(:order) { create(:order_with_proofs) }
  given(:proof) { order.proofs.first }
  before(:each) do
    login_as(valid_user)
    allow(Order).to receive(:find).and_return(order)
    allow(order).to receive(:artwork_requests).and_return([artwork_request])
  end

  scenario 'A user can view a list of Proofs', js: true do
    visit root_path
    unhide_dashboard
    click_link 'Orders'
    find("a[href='/orders']").click
    find("a[href='/orders/#{order.id}/edit']").click
    find("a[href='#proofs']").click
    expect(page).to have_selector('h3', text: 'Proofs')
    expect(page).to have_css("div.proof-list")
    expect(page).to have_css("div#proof-#{proof.id}")
  end

  scenario 'A user can create a Proof', js: true do
    visit edit_order_path(order.id)
    find("a[href='#proofs']").click
    find("a[href='/orders/#{order.id}/proofs/new']").click
    fill_in 'proof_approve_by', with: '01/23/1992 8:55 PM'
    sleep 0.5
    find(:css, "div.icheckbox_minimal-grey[aria-checked='false']").click
    sleep 0.5
    page.execute_script("$('.icheckbox_minimal-grey').attr('aria-checked', 'true')")
    sleep 0.5
    click_button 'Create Proof'
    expect(page).to have_selector('.modal-content-success')
    sleep 0.5
    find(:css, "button.close").click
    sleep 0.5
    expect(page).to have_css("div#proof-#{proof.id}")
    expect(Proof.where(id: proof.id)).to exist
  end

  scenario 'A user can edit and update an Proof from the Proof List', js: true  do
    visit edit_order_path(order.id)
    find("a[href='#proofs']").click
    find("a[href='#{edit_order_proof_path(id: proof.id, order_id: order.id)}']").click
    fill_in 'proof_approve_by', with: '01/23/2012 8:55 PM'
    sleep 0.5
    click_button 'Update Proof'
    expect(page).to have_selector('.modal-content-success')
    sleep 0.5
    find(:css, "button.close").click
    expect(page).to have_css("div#proof-#{proof.id}")
    expect(Proof.where(id: proof.id)).to exist
  end

  scenario 'A user can delete an Proof from the Proof List', js: true do
    visit edit_order_path(order.id)
    find("a[href='#proofs']").click
    find("a[href='#{order_proof_path(id: proof.id, order_id: order.id)}']").click
    expect(page).to have_selector('.modal-content-success')
    sleep 0.5
    find(:css, "button.close").click
    expect(page).to_not have_css("div#proof-#{proof.id}")
    expect(Proof.where(id: proof.id)).to_not exist
  end

  scenario 'A user can Approve a Proof from the Proof List', js: true do
    visit edit_order_path(order.id)
    find("a[href='#proofs']").click
    click_link 'Accept Proof'
    sleep 5
    page.driver.browser.switch_to.alert.accept
    sleep 0.5
    expect(page).to have_selector('.modal-content-success')
    sleep 0.5
    find(:css, "button.close").click
    expect(Proof.find(proof.id).status).to eq('Approved')

  end

  scenario 'A user can Reject a Proof from the Proof List', js: true do
    visit edit_order_path(order.id)
    find("a[href='#proofs']").click
    click_link 'Reject Proof'
    page.driver.browser.switch_to.alert.accept
    sleep 0.5
    expect(page).to have_selector('.modal-content-success')
    sleep 0.5
    find(:css, "button.close").click
    expect(Proof.find(proof.id).status).to eq('Rejected')

  end

  scenario 'A user can Email a Customer a Proof Approval Request from the Proof List', js: true do
    visit edit_order_path(order.id)
    find("a[href='#proofs']").click
    find("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'false')}']").click
    sleep 0.5
    click_button 'Send Email'
    sleep 0.5
    expect(page).to have_selector('.modal-content-success')
    sleep 0.5
    find(:css, "button.close").click
    expect(Proof.find(proof.id).status).to eq('Emailed Customer')
    expect(Proof.find(proof.id).status).to_not eq('Pending')

  end

  scenario 'A user can Email a Reminder to the Customer from the Proof List', js: true do
    proof.status = 'Emailed Customer'
    proof.save
    visit edit_order_path(order.id)
    find("a[href='#proofs']").click
    find("a[href='#{email_customer_order_proofs_path(id: proof.id, order_id: order.id, reminder: 'true')}']").click
    page.driver.browser.switch_to.alert.accept
    sleep 0.5
    expect(Proof.find(proof.id).status).to eq('Emailed Customer')
    expect(Proof.find(proof.id).status).to_not eq('Pending')
  end
end