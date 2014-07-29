require 'spec_helper'
include ApplicationHelper

describe Artwork, artwork_spec: true do

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
  end

  describe 'Relationships' do
    it { should belong_to(:artist) }
    it { should have_one(:preview) }
    it { should have_one(:artwork) }
    it { should have_and_belong_to_many(:artwork_requests) }
    it { should accept_nested_attributes_for(:artwork)}
    it { should accept_nested_attributes_for(:preview)}
  end

end