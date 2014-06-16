require 'spec_helper'

describe 'orders/_imprint.html.erb', order_spec: true, imprint_spec: true do
  let!(:order) { create(:order_with_job) }
  let(:job) { order.jobs.first }

  let(:imprint_method) { create(:valid_imprint_method_with_color_and_location) }
  let(:print_location) { imprint_method.print_locations.first }
  let(:print_location2) { create(:print_location, imprint_method_id: imprint_method.id, name: 'pl2') }

  let(:imprint) { create(:imprint, 
    job_id: job.id, print_location_id: print_location.id
  ) }

  context 'with an imprint method' do
    let!(:imprint_method2) { create(:valid_imprint_method_with_color_and_location, name: 'imp2') }
    let!(:imprint_method3) { create(:valid_imprint_method_with_color_and_location, name: 'imp3') }

    it 'should render a select box for imprint methods and print locations' do
      render partial: 'orders/imprint', locals: { job: job, imprint_method: imprint_method }
      expect(rendered).to have_css 'select[name="imprint_method"]'
      expect(rendered).to have_css 'select[name="print_location"]'
    end

    it 'should render the local imprint method as the first option' do
      render partial: 'orders/imprint', locals: { job: job, imprint_method: imprint_method }
      expect(rendered).to have_css 'option:first-child', text: imprint_method.name
    end

    it 'should render the print location as the first option' do
      print_location; print_location2
      imprint.print_location = print_location2
      imprint.save
      render partial: 'orders/imprint', locals: { job: job, imprint_method: imprint.imprint_method, imprint_id: imprint.id }
      expect(rendered).to have_css 'option:first-child', text: imprint.print_location.name
    end
  end
end