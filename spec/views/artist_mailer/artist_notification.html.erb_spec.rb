require 'spec_helper'

describe 'artist_mailer/artist_notification.html.erb', artist_mailer_spec: true do
  let!(:salesperson) { create(:user) }
  let!(:order) { create :order_with_job }
  let!(:artwork_request) { create(:valid_artwork_request,
                                        imprints: [build(:valid_imprint, job: order.jobs.first)],
                                        deadline: DateTime.now) }
  let!(:action_name) { 'update' }

  it 'includes the name of the salesperson, the imprint method, the print location, the jobs, the order, the proof deadline, and the priority' do
    assign(:salesperson, salesperson)
    assign(:artwork_request, artwork_request)
    assign(:action_name, action_name)
    render
    expect(rendered).to have_text("Imprint(s):")
    expect(rendered).to have_text(artwork_request.imprints.first.name)
    expect(rendered).to have_text("Jobs: #{artwork_request.jobs.map(&:name).join(', ')}")
    expect(rendered).to have_text("Order: #{order.name}")
    expect(rendered).to have_text("Proof Deadline: #{display_time(artwork_request.deadline)}")
    expect(rendered).to have_text("Priority: #{ArtworkRequest::PRIORITIES[artwork_request.priority.to_i]}")
    expect(rendered).to have_text("#{salesperson.full_name} has #{action_name}d an Artwork Request for")
  end
end
