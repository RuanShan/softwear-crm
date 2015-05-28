require 'spec_helper'

describe 'public_activity/quote/_update.html.erb' do
  let!(:activity1) { build_stubbed(:quote_activity_update) } 
  
  before(:each) do 
      render partial: 'public_activity/quote/update', locals: {activity: activity1 }
  end 

  context 'first_name field was changed on quote' do 
    it 'has first_name is changed, and the previous and new values' do
     expect(rendered).to have_text("From: Bob")
     expect(rendered).to have_text("To: Jim")
    end
  end
end
