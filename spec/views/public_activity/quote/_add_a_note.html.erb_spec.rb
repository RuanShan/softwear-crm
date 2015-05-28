require 'spec_helper'

  describe 'public_activity/quote/_add_a_note.html.erb' do
    let!(:activity1) { build_stubbed(:quote_activity_note) } 
    
    before(:each) do 
        render partial: 'public_activity/quote/add_a_note', locals: {activity: activity1 }
    end 

    context 'new notes added to quote' do 
      it 'has appropriate note fields listed in the timeline' do
       expect(rendered).to have_text("ID: 1")
       expect(rendered).to have_text("ID: 2")
       expect(rendered).to have_text("Title: Hello")
       expect(rendered).to have_text("Title: Goodbye")
       expect(rendered).to have_text("Comment: This is note")
       expect(rendered).to have_text("Comment: Mr. Note")
    end
  end
end
