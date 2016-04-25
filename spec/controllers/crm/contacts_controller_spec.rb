require 'spec_helper'

describe Crm::ContactsController, type: :controller do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  describe 'POST #create' do
    context 'with valid data including a phone and e-mail' do
      it 'creates a contact, e-mail, and phone number' do
        expect {
          post :create, { :crm_contact => {
                          :first_name => 'First', last_name: 'Last',
                          :primary_email_attributes => { address: 'email@sample.com', primary: true },
                          :primary_phone_attributes => { number: '555-555-5555', primary: true },
                        }
                      }
        }.to change{ Crm::Contact.count }.from(0).to(1)
        expect(Crm::Email.where(address: 'email@sample.com').count).to be > 0
        expect(Crm::Phone.where(number: '555-555-5555').count).to be > 0
      end
    end

  end


end
