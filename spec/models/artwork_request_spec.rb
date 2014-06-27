require 'spec_helper'

describe ArtworkRequest, artwork_request_spec: true do

  describe 'Validations' do
    it { should validate_presence_of(:deadline) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:imprint_method_id) }
    it { should validate_presence_of(:artwork_status) }
    it { should validate_presence_of(:print_location_id) }
    it { should validate_presence_of(:job_ids) }
    it { should validate_presence_of(:ink_color_ids) }
    it { should validate_presence_of(:artist_id) }
    it { should validate_presence_of(:salesperson_id) }
  end

  describe 'Relationships' do
    # it { should belong_to(:user) }
    it { should belong_to(:imprint_method) }
    it { should belong_to(:print_location) }
    it { should have_many(:assets) }
    it { should have_and_belong_to_many(:jobs) }
    it { should have_and_belong_to_many(:ink_colors) }

  end

end