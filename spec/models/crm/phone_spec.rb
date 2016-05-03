require 'spec_helper'

describe Crm::Phone, type: :model do
  describe 'Relationships' do
    it { is_expected.to belong_to(:contact)}
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :number }
    it { is_expected.to allow_value('123-654-9871').for :number }
    it { is_expected.to allow_value('1236549871').for :number and expect(subject.number).to eq '123-654-9871' }
    it { is_expected.to allow_value('(123) 654-9871').for :number and expect(subject.number).to eq '123-654-9871' }
    it { is_expected.to_not allow_value('134e6').for(:number)
                              .with_message('is incorrectly formatted, use 000-000-0000') }
  end

end
