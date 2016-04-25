require 'spec_helper'

describe Crm::Phone, type: :model do
  describe 'Relationships' do
    it { is_expected.to belong_to(:contact)}
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :number }
    it { is_expected.to allow_value('123-654-9871').for :number }
    it { is_expected.to_not allow_value('135184e6').for(:number)
                              .with_message('is incorrectly formatted, use 000-000-0000') }
  end

end
