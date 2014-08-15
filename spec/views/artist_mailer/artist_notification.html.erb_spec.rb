require 'spec_helper'

describe 'artist_mailer/artist_notification.html.erb', artist_mailer_spec: true do
  let!(:salesperson){ build_stubbed(:blank_user) }
  let!(:artwork_request){ build_stubbed(:blank_artwork_request,
                                        jobs: [build_stubbed(:blank_job,
                                                             order: build_stubbed(:blank_order))],
                                        imprint_method: build_stubbed(:blank_imprint_method),
                                        print_location: build_stubbed(:blank_print_location),
                                        deadline: DateTime.now) }
  let!(:action_name){ 'update' }

  it 'includes the name of the salesperson, the imprint method, the print location, the jobs, the order, the proof deadline, and the priority' do
    assign(:salesperson, salesperson)
    assign(:artwork_request, artwork_request)
    assign(:action_name, action_name)
    render
    expect(rendered).to have_text("Imprint Method: #{artwork_request.imprint_method.name}, #{artwork_request.print_location.name}")
    expect(rendered).to have_text("Jobs: #{artwork_request.jobs.map(&:name).join(', ')}")
    expect(rendered).to have_text("Order: #{artwork_request.jobs.first.order.name}")
    expect(rendered).to have_text("Proof Deadline: #{display_time(artwork_request.deadline)}")
    expect(rendered).to have_text("Priority: #{ArtworkRequest::PRIORITIES[artwork_request.priority.to_i]}")
    expect(rendered).to have_text("#{salesperson.full_name} has #{action_name}d an Artwork Request for")

  end
end
