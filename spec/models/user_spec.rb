require 'spec_helper'

describe User, user_spec: true do

  it { is_expected.to be_paranoid }

  describe 'Relationships' do
    it { is_expected.to belong_to(:store) }
    # FIXME this doesn't work
    # it { is_expected.to have_many(:orders) }
    it { is_expected.to have_many(:search_queries).class_name('Search::Query') }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }

    it { is_expected.to allow_value('test@annarbortees.com').for :email }
    it { is_expected.to_not allow_value('invalidemail').for :email }
  end

  describe '#full_name' do
    let!(:user) { build_stubbed(:blank_user, first_name: 'First', last_name: 'Last') }

    subject do
      build_stubbed(
        :blank_user,
        first_name: 'First', last_name: 'Last'
      )
        .full_name
    end

    it { is_expected.to eq 'First Last' }
  end

  describe '.customer', customer: true do
    it "returns a user with the email address 'customer@softwearcrm.com' and #customer? is true" do
      expect(User.customer.email).to eq 'customer@softwearcrm.com'
      expect(User.customer.customer?).to eq true
    end
  end
end
