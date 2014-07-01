require 'spec_helper'

describe PrintLocation do

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:max_height) }
    it { should validate_presence_of(:max_width) }
    it { should validate_numericality_of (:max_height) }
    it { should validate_numericality_of(:max_width) }
    # it { should validate_uniqueness_of(:name).scoped_to(:deleted_at}
    # figure out a way to include conditions: -> { where(deleted_at: nil)} into the validation
  end


  describe 'Relationships' do
    it { should belong_to(:imprint_method) }
    it { should have_many :imprints }
  end

end