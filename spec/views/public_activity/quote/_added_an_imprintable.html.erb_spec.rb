require 'spec_helper'

  describe 'public_activity/quote/_added_an_imprintable.html.erb' do
    let!(:activity1) { build_stubbed(:quote_activity_add_imprintable) } 
    
    before(:each) do 
        render partial: 'public_activity/quote/added_an_imprintable', locals: {activity: activity1 }
    end 

    context 'new imprintable added to quote' do 
      it 'has appropriate fields listed in the timeline: '\
       "quantity, decoration price, imprintable price,"\
      "tier, and group_id" do
       expect(rendered).to have_text("With a quantity of: 100")
       expect(rendered).to have_text("With a quantity of: 130")
       expect(rendered).to have_text("With a decoration price of: $1.5")
       expect(rendered).to have_text("With a decoration price of: $1.33")
       expect(rendered).to have_text("With an imprintable price of: $0.7")
       expect(rendered).to have_text("With an imprintable price of: $0.9")
       expect(rendered).to have_text("Tier: 3")
       expect(rendered).to have_text("Tier: 1")
       expect(rendered).to have_text("Group_ID: 3")
       expect(rendered).to have_text("Group_ID: 1")
       expect(rendered).to have_text("Added Imprintable(s) 1")
       expect(rendered).to have_text("Added Imprintable(s) 4")
    end
  end
end
