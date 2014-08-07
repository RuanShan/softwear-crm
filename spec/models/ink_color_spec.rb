require 'spec_helper'

describe InkColor do

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    #TODO Nigel thinks the rspec shoulda matchers just aren't working with his uniqueness/scoped/deleted_at patch
    # it { should validate_uniqueness_of(:name).scoped_to(:imprint_method) }
  end

  describe 'Relationships' do
    it { should belong_to(:imprint_method) }
  end

end