require 'spec_helper'

  describe 'public_activity/quote/_added_line_item_group.html.erb' do
    let!(:activity1) { build_stubbed(:quote_activity_line_item) } 
    
    before(:each) do 
        render partial: 'public_activity/quote/added_line_item', locals: {activity: activity1 }
    end 

    context 'new line item group added to quote' do 
      it 'has appropriate fields listed in the timeline' do
       expect(rendered).to have_text("With a quantity of: 12")
       expect(rendered).to have_text("With a quantity of: 100")
     expect(rendered).to have_text("With a decoration price of: $6.66")
     expect(rendered).to have_text("With an imprintable price of: $20.33")
     expect(rendered).to have_text("1-blue")
     expect(rendered).to have_text("group1")
     expect(rendered).to have_text("For the line item: 2")
    end
  end
end
