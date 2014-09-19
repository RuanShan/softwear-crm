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
            name_number: { name: 'test name', number: '2' }
          }
        }
      }
    end

    it 'properly assigns name/number fields' do
      expect(NameNumber.where(name: 'test name')).to_not exist
      expect(imprint.has_name_number).to_not be_truthy
      expect(imprint.name_number).to be_nil

      put :update, name_number_params.merge(job_id: job.id, format: :js)

      imprint.reload
      expect(imprint.has_name_number).to eq true
      expect(NameNumber.where(name: 'test name')).to exist
      expect(imprint.name_number).to eq NameNumber.find_by(name: 'test name')
    end
  end
end