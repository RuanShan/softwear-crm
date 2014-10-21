require 'spec_helper'

describe 'imprints/_imprint.html.erb', order_spec: true, imprint_spec: true do
  let!(:order) { create(:order_with_job) }
  let(:job) { order.jobs.first }

  let(:imprint_method) { create(:valid_imprint_method) }
  let(:print_location) { imprint_method.print_locations.first }
  let(:print_location2) { create(:print_location, imprint_method_id: imprint_method.id, name: 'pl2') }

  let(:imprint) { create(:blank_imprint, 
    job_id: job.id, print_location_id: print_location.id
  ) }

  context 'when there are no imprint methods' do
    it 'should inform the user of this' do
      render partial: 'imprints/imprint'
      expect(rendered).to have_content "Looks like there aren't any Imprint Methods registered."
    end

    it 'should provide a link to create one' do
      render partial: 'imprints/imprint'
      expect(rendered).to have_css "a[href='#{new_imprint_method_path}']"
    end
  end

  context 'with an imprint method' do
    let!(:imprint_method2) { create(:valid_imprint_method, name: 'imp2') }
    let!(:imprint_method3) { create(:valid_imprint_method, name: 'imp3') }

    it 'should render a select box for imprint methods and print locations' do
      render partial: 'imprints/imprint', locals: { job: job, imprint_method: imprint_method }
      expect(rendered).to have_css 'select[name="imprint_method"]'
      expect(rendered).to have_css 'select[name*="print_location"]'
    end

    it 'should render the local imprint method as the default option' do
      pending "The version of Nokogiri used by Rspec doesn't support the :checked pseudoclass, "\
              "so there's no way to test for this outside of feature specs."

      render partial: 'imprints/imprint', locals: { job: job, imprint_method: imprint_method }
      expect(rendered).to have_css 'option:checked', text: imprint_method.name
    end

    it 'should render the print location as the default option' do
      pending "The version of Nokogiri used by Rspec doesn't support the :checked pseudoclass, "\
              "so there's no way to test for this outside of feature specs."

      print_location; print_location2
      imprint.print_location = print_location2
      imprint.save
      render partial: 'imprints/imprint', locals: { job: job, imprint_method: imprint.imprint_method, imprint_id: imprint.id }
      expect(rendered).to have_css 'option:checked', text: imprint.print_location.name
    end
  end
end