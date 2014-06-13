require 'spec_helper'

describe 'orders/_imprint.html.erb', order_spec: true, imprint_spec: true do
  let!(:order) { create(:order_with_job) }
  let(:job) { order.jobs.first }

  let(:imprint_method) { create(:valid_imprint_method_with_color_and_location) }
  let(:print_location) { imprint_method.print_location }

  let(:imprint) { create(:imprint, 
    job_id: job.id, print_location_id: print_location.id
  ) }

  context 'with no locals' do
    it 'should only render a select box for imprint methods' do
      render partial: 'orders/imprint', locals: { job: job }
      expect(rendered).to have_css 'select[name="imprint_method"]'
      expect(rendered).to_not have_css 'select[name="print_location"]'
    end
  end

  context 'with an imprint method' do
    let!(:imprint_method2) { create(:valid_imprint_method_with_color_and_location, name: 'imp2') }
    let!(:imprint_method3) { create(:valid_imprint_method_with_color_and_location, name: 'imp3') }

    before(:each) do
      render partial: 'orders/imprint', locals: { job: job, imprint_method: imprint_method }
    end

    it 'should render a select box for imprint methods and print locations' do
      expect(rendered).to have_css 'select[name="imprint_method"]'
      expect(rendered).to have_css 'select[name="print_location"]'
    end

    it 'should render the local imprint method as the first option' do
      expect(rendered).to have_css 'option:first-child', text: imprint_method.name
    end
  end
end