require 'spec_helper'

describe 'public_activity/proof/_create.html.erb', proof_spec: true do
  let!(:activity) { create(:proof_activity, owner: current_user) }
  let!(:current_user) { create :user }

  it 'has trackable_type, trackable, and recipient' do
    render partial: 'public_activity/proof/create', locals: {activity: activity, current_user: current_user}
    expect(rendered).to have_text('Added proof by ' + current_user.full_name + ' to')
    expect(rendered).to have_selector('a', text: activity.recipient.name)
  end

  it 'has trackable_type and recipient but not trackable' do
    activity.trackable_id = nil
    render partial: 'public_activity/proof/create', locals: {activity: activity, current_user: current_user}
    expect(rendered).to have_text('Added proof which has since been removed to')
    expect(rendered).to have_selector('a', text: activity.recipient.name)
  end

  it 'doesnt have trackable_type but does have recipient' do
    activity.trackable = nil
    render partial: 'public_activity/proof/create', locals: {activity: activity, current_user: current_user}
    expect(rendered).to have_text('Added some proof... to')
    expect(rendered).to have_selector('a', text: activity.recipient.name)
  end

  it 'doesnt have trackable_type or recipient' do
    activity.trackable = nil
    activity.recipient = nil
    render partial: 'public_activity/proof/create', locals: {activity: activity, current_user: current_user}
    expect(rendered).to have_text('Added some proof... to a deleted order')
  end

end
