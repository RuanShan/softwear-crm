require 'spec_helper'

describe Crm::Email, type: :model do
  describe 'Relationships' do
    it { is_expected.to belong_to(:contact) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :address }
    it { is_expected.to allow_value('test@example.com').for :address }
    it { is_expected.to_not allow_value('not_an-email').for :address }
  end

end
