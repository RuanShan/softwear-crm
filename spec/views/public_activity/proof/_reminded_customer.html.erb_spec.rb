require 'spec_helper'

describe 'public_activity/proof/_reminded_customer.html.erb', proof_spec: true do
  let!(:activity) { create(:proof_activity) }
  let!(:current_user) { create :user }

  it 'has trackable_type, trackable, and recipient' do
    render partial: 'public_activity/proof/reminded_customer', locals: {activity: activity, current_user: current_user}
    expect(rendered).to have_text('Sent customer proof approval reminder by ' + current_user.full_name + ' in')
    expect(rendered).to have_selector('a', text: activity.recipient.name)
  end

  it 'has trackable_type and recipient but not trackable' do
    activity.trackable_id = nil
    render partial: 'public_activity/proof/reminded_customer', locals: {activity: activity, current_user: current_user}
    expect(rendered).to have_text('Sent customer proof approval reminder which has since been removed in')
    expect(rendered).to have_selector('a', text: activity.recipient.name)
  end

  it 'doesnt have trackable_type but does have recipient' do
    activity.trackable = nil
    render partial: 'public_activity/proof/reminded_customer', locals: {activity: activity, current_user: current_user}
    expect(rendered).to have_text('Sent some proof approval reminder... in')
    expect(rendered).to have_selector('a', text: activity.recipient.name)
  end

  it 'doesnt have trackable_type or recipient' do
    activity.trackable = nil
    activity.recipient = nil
    render partial: 'public_activity/proof/reminded_customer', locals: {activity: activity, current_user: current_user}
    expect(rendered).to have_text('Sent some proof approval reminder... in a deleted order')
  end

end