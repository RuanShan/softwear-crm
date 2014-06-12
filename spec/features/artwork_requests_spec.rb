require 'spec_helper'
include ApplicationHelper

feature 'Proof Request Features' do
  given!(:valid_user) { create(:alternate_user) }
  before(:each) do
    login_as(valid_user)
  end

  # given!(:proof_request) { create(:valid_proof_request)}
  # NEED TO IMPLEMENT AN ARTWORK REQUEST FACTORY
  #
  # scenario 'A user can create ONE artwork request' , js: true do
  #   visit orders_path
  #   THIS GOES DIRECTLY TO THE ORDERS PATH, WHERE EVERYTHING IS PRESENTED IN A TABLE
  #   find("tr#order_#{order.id} a[data-action='edit']").click
  #   THIS FINDS AND CLICKS THE EDIT BUTTON (NO OTHER WAY TO GET TO ARTWORK REQUESTS AT THE MOMENT)
  #   click_link 'Artwork'
  #   THIS CLICKS ON THE ARTWORK TAB SO THAT WE CAN INPUT THE INFORMATION
  #   find(:css, "input[class='token-input job-name']").set('Sample Job Name')
  #   THIS CLICKS THE TOKEN INPUT FIELD AND TYPES IN A VALUE
  #   find(:css, "div[class='dropdown imprint-names']").click
  #   click_link 'Sample Dropdown Menu Item aka Name-Production Name'
  #   FIGURE OUT IF THIS IS THE CORRECT WAY TO CLICK ON SOMETHING IN THE DROPDOWN MENU
  #   find(:css, "div[class='dropdown artist-name']").click
  #   click_link 'Sample Artist Name'
  #   find(:css, "div[class='dropdown location']").click
  #   click_link 'Location Based On Imprint Name'
  #   find(:css, "div[class='dropdown status']").click
  #   click_link 'Status of the Request'
  #   ADD THE CHECKBOXES FOR INK COLORS, THE WYSIWYG FOR DESCRIPTION AND ADDITIONAL NOTES
  #   expect(ImprintMethod.where(name: 'New Imprint Method Name')).to exist
  #   expect(ImprintMethod.where(production_name: 'New Production Name')).to exist
  #   expect(page).to have_selector('#flash_notice', text: 'Imprint method was successfully created.')
  # end

end