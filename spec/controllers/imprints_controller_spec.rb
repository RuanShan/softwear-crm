require 'spec_helper'

describe ImprintsController, imprint_spec: true do
  let(:print_location) { create :print_location }
  let(:job) { create :job }
  let(:imprint) { create :imprint, 
                          print_location_id: print_location.id,
                          job_id: job.id }

  it_can 'batch update'

  describe '#update' do
    let(:name_number_params) do
      {
        imprint: {
          imprint.id.to_s => {
            has_name_number: true,
            name_number: { name: 'test name', number: '2' }
          }
        }
      }
    end

    it 'properly assigns name/number fields' do
      expect(NameNumber.where(name: 'test name')).to_not exist
      expect(imprint.has_name_number).to eq false
      expect(imprint.name_number).to be_nil

      put :update, name_number_params

      expect(NameNumber.where(name: 'test name')).to exist
      expect(imprint.has_name_number).to eq true
      expect(imprint.name_number).to eq NameNumber.find_by(name: 'test name')
    end
  end
end