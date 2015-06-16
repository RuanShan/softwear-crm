require 'spec_helper'

  describe 'public_activity/quote/_add_a_markup.html.erb' do
    let!(:activity1) { build_stubbed(:quote_activity_markup) } 
    
    before(:each) do 
        render partial: 'public_activity/quote/add_a_markup', locals: {activity: activity1 }
    end 

    context 'new notes added to quote' do 
      it 'has appropriate note fields listed in the timeline: '\
       ' name, description, url, and unit price' do
       expect(rendered).to have_text("Name: Mo Money")
       expect(rendered).to have_text("Description: Mo Problems")
       expect(rendered).to have_text("URL: www.money.com")
       expect(rendered).to have_text("Unit Price: 664")
    end
  end
end
