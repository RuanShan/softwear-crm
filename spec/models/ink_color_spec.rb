require 'spec_helper'

describe InkColor do

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    # it { should validate_uniqueness_of(:name).scoped_to(:imprint_method) }
    # figure out a way to include conditions: -> { where(deleted_at: nil)} into the validation
  end

  describe 'Relationships' do
    it { should belong_to(:imprint_method) }
  end

end