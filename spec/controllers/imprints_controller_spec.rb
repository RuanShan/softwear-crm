require 'spec_helper'

describe ImprintsController, imprint_spec: true do
  let!(:valid_user) { create :alternate_user }
  before(:each) { sign_in valid_user }

  let(:print_location) { create :print_location }
  let(:job) { create :job }
  let(:imprint) { create :valid_imprint, 
                          print_location_id: print_location.id,
                          job_id: job.id }

  it_can 'batch update'

  describe '#update' do
    let(:name_number_params) do
      {
        imprint: {
          imprint.id.to_s => {
            has_name_number: '1',
            name_format: 'name format',
            number_format: 'number format'
          }
        }
      }
    end

    it 'properly assigns name/number fields', story_189: true do
      expect(imprint.name_format).to be_nil

      put :update, name_number_params.merge(job_id: job.id, format: :js)

      imprint.reload
      expect(imprint.name_format).to eq 'name format'
      expect(imprint.number_format).to eq 'number format'
    end
  end
end