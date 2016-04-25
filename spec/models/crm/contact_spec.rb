require 'spec_helper'

describe Crm::Contact, type: :model do
  describe 'Relationships' do
    it { is_expected.to have_many :emails }
    it { is_expected.to have_many :phones }
    # it { is_expected.to have_many :orders }
    # it { is_expected.to have_many :quotes }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :primary_email }
    it { is_expected.to validate_presence_of :primary_phone }
  end

  it{ should accept_nested_attributes_for :emails }
  it{ should accept_nested_attributes_for :phones }
  it{ should accept_nested_attributes_for :primary_email }
  it{ should accept_nested_attributes_for :primary_phone }

  describe 'phone_number' do
    context 'when the primary_phone has an extension' do
      let(:contact) { create(:crm_contact, primary_phone: create(:crm_phone_with_extension) ) }

      it 'returns the primary_phone number + extension' do
        expect(contact.phone_number).to eq("#{contact.primary_phone.number}x#{contact.primary_phone.extension}")
      end
    end

    context 'when the primary_phone has no extension' do
      let(:contact) { create(:crm_contact) }


      it 'returns the primary_phone number' do
        expect(contact.phone_number).to eq(contact.primary_phone.number)
      end
    end
  end

  describe 'email' do
    let(:contact) { create(:crm_contact) }

    it 'returns the primary_email address' do
      expect(contact.email).to eq(contact.primary_email.address)
    end
  end

end
