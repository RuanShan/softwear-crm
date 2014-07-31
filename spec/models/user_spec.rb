require 'spec_helper'

describe User, user_spec: true do
  describe 'Relationships' do
    it { should belong_to :store }
  end

  context 'when validating' do
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :email }

    it { should allow_value('test@annarbortees.com').for :email }
    it { should_not allow_value('invalidemail').for :email }
  end

  context 'is non-deletable, and' do
    let!(:user) {create(:user)}

    it 'destroyed? returns false when not deleted' do
      expect(user.destroyed?).to eq false
    end
    it 'destroyed? returns true when deleted' do
      user.destroy
      expect(user.destroyed?).to eq true
    end

    it 'still exists after destroy is called' do
      user.destroy
      expect(User.deleted).to include user
    end
    it 'is not accessible through the default scope once destroyed' do
      user.destroy
      expect(User.all).to_not include user
    end
  end
end