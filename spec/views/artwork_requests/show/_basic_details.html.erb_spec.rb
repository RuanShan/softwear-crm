require 'spec_helper'

describe 'artwork_requests/show/_basic_details.html.erb', artwork_request_spec: true, type: :view do

  let(:artwork_request) { create(:valid_artwork_request) }
  before{ render 'artwork_requests/show/basic_details', artwork_request: artwork_request }

  it 'renders a dl, no div, with Job, State, Imprint Method, Max Print Area'\
      ', Ink Colors, No. of Pieces, Exact Recreation,' do 
    expect(rendered).not_to have_css(:div)
    expect(rendered).to have_css(:dt, text: 'Job')
    expect(rendered).to have_css(:dd, text: artwork_request.jobs.map(&:id_and_name).join(', ') )
    expect(rendered).to have_css(:dt, text: 'State')
    expect(rendered).to have_css(:dd, text: artwork_request.state )
    expect(rendered).to have_css(:dt, text: 'Imprint Method')
    expect(rendered).to have_css(:dd, text: artwork_request.imprint_method_names.map(&:id_and_name).join(', ') )
    expect(rendered).to have_css(:dt, text: 'Max Print Area')
    expect(rendered).to have_css(:dd, text: artwork_request.max_print_area(artwork_request.print_location) )
    expect(rendered).to have_css(:dt, text: 'Ink Colors')
    expect(rendered).to have_css(:dd, text: artwork_request.ink_colors.map(&:display_name).join(', ') )
    expect(rendered).to have_css(:dt, text: 'No. of Pieces')
    expect(rendered).to have_css(:dd, text: artwork_request.imprintable_variant_count )
    expect(rendered).to have_css(:dt, text: 'Exact Recreation')
    expect(rendered).to have_css(:dd, text: human_boolean(artwork_request.exact_recreation?) )
    expect(rendered).not_to have_css(:dt, text: 'Customer Paid For Artwork')
  end

  context 'customer paid for artwork > 0.0' do 
    let(:artwork_request) { create(:valid_artwork_request, amount_paid_for_artwork: 5.0) }
    it 'displays amount paid for artwork' do 
      expect(rendered).to have_css(:dt, text: 'Customer Paid For Artwork')
      expect(rendered).to have_css(:dd, text: number_to_currency(artwork_request.amount_paid_for_artwork) )
    end
  end

  context "variable 'full' is defined" do 
    before do 
      artwork_request.artist = create(:user)
      render 'artwork_requests/show/basic_details', artwork_request: artwork_request, full: true 
    end

    it 'renders the view as two col-sm-6 columns' do 
      expect(rendered).to have_css("div.col-sm-6")
    end

    it 'renders priority, deadline, order salesperson, request creator, and artist' do 
      expect(rendered).to have_css(:dt, text: 'Priority')
      expect(rendered).to have_css(:dd, text: ArtworkRequest::PRIORITIES[artwork_request.priority.to_i] )
      expect(rendered).to have_css(:dt, text: 'Deadline')
      expect(rendered).to have_css(:dd, text: display_time(artwork_request.deadline) )
      expect(rendered).to have_css(:dt, text: 'Order Salesperson')
      expect(rendered).to have_css(:dd, text: artwork_request.order.salesperson.full_name )
      expect(rendered).to have_css(:dt, text: 'Request Created By')
      expect(rendered).to have_css(:dd, text: artwork_request.salesperson.full_name )
      expect(rendered).to have_css(:dt, text: 'Artist')
      expect(rendered).to have_css(:dd, text: artwork_request.artist.full_name )
    end
  end
end
