require 'spec_helper'
include ApplicationHelper

feature 'Contacts Management', contact_spec: true do

  feature 'As a logged in user' do
    given!(:valid_user) { create(:alternate_user) }
    background(:each) { sign_in_as(valid_user) }

    feature 'given contacts exist' do
      given!(:contact) { create(:crm_contact) }


      scenario 'I can see a list of all contacts', no_ci: true, js: true do
        visit root_path

        allow_any_instance_of(SunspotMatchers::SunspotSearchSpy).to\
          receive(:results) { Kaminari.paginate_array(Crm::Contact.all.to_a).page(1).per(10) }

        allow_any_instance_of(Kaminari::PaginatableArray).to\
          receive(:total_entries) { Crm::Contact.count }

        click_link 'Contacts'
        within "#nav_contacts_menu" do
          click_link 'List'
        end

        expect(page).to have_css('table#contacts')
        expect(page).to have_css("tr#contact_#{contact.id}")
      end

      scenario 'I can filter my contacts based on their state'
      scenario 'I can search my contacts'

      scenario 'I can modify an existing contact', current: true do
        visit crm_contact_path(contact)
        within('.contacts-show') do
          click_link 'Edit'
        end
        fill_in "First name", with: 'First'
        fill_in "Last name", with: 'Last'
        fill_in "E-mail", with: 'sample2@sample.com'
        fill_in "Phone", with: '555-555-5555'
        click_button 'Update Contact'
        contact.reload
        expect(contact.first_name).to eq('First')
        expect(contact.last_name).to eq('Last')
        expect(contact.email).to eq('sample2@sample.com')
        expect(contact.phone_number).to eq('555-555-5555')
      end

      scenario 'I can destroy a contact that has no associated orders, quotes, or quote requests'
      scenario 'I cannot destroy a contact that has no associated orders, quotes, or quote requests'

      scenario 'I can add phone numbers and e-mails to a contact', current: true,  js: true do
        visit edit_crm_contact_path(contact)

        click_link "Add Email"
        within all('.email-fields').last do
          fill_in "E-mail", with: 'sample2@sample.com'
        end

        click_link "Add Phone Number"
        within all('.phone-fields').last do
          fill_in "Phone", with: '555-555-5555'
          check 'Primary'
        end
        click_button 'Update Contact'

        contact.reload
        expect(contact.emails.count).to eq(2)
        expect(contact.phones.count).to eq(2)
      end

      scenario 'I can view the orders that a contact has'
      scenario 'I can view the quotes that a contact has'
      scenario 'I can view the quote requests that a contact has'
    end

    scenario 'I can create a new contact with good inputs' do
      expect {
        visit root_path
        click_link 'Contacts'
        within "#nav_contacts_menu" do
          click_link 'New'
        end
        fill_in "First name", with: 'Sample'
        fill_in "Last name", with: 'Contact'
        fill_in "E-mail", with: 'sample@sample.com'
        fill_in "Phone", with: '555-555-1212'
        click_button "Create Contact"
      }.to change{ Crm::Contact.count }.from(0).to(1)
    end



  end

end
