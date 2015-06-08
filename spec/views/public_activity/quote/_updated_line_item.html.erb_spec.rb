require 'spec_helper'

  describe 'public_activity/quote/_updated_line_item.html.erb' do
    let!(:activity1) { build_stubbed(:quote_activity_line_item_update) } 
    
    before(:each) do 
        render partial: 'public_activity/quote/updated_line_item', locals: {activity: activity1 }
    end 

    context 'line item groups added to quote' do 
      it 'has appropriate fields listed in the timeline:'\
       " quantity, decoration price, imprintable price, name "\
      "imprint description, and imprint location ID" do
       expect(rendered).to have_text("From a quantity of: 12 to 40")
       expect(rendered).to have_text("From a decoration price of: $5.0 to $10.0")
       expect(rendered).to have_text("From an imprintable price of: $8.0 to $18.0")
       expect(rendered).to have_text("From location ID: 3 to 4")
       expect(rendered).to have_text("From 1-blue to 14-orange")
       expect(rendered).to have_text("From 4-green to 3-red")
    end
  end
end
