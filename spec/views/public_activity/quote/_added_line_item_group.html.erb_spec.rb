require 'spec_helper'

  describe 'public_activity/quote/_added_line_item_group.html.erb' do
    let!(:activity1) { build_stubbed(:quote_activity_line_item_group) } 
    
    before(:each) do 
        render partial: 'public_activity/quote/added_line_item_group', locals: {activity: activity1 }
    end 

    context 'new line item group added to quote' do 
      it "displays the imprints names, locations and descriptions "\
         "and it displays line item quantity, decoration price and "\
         "group name. It also displays each imprintables name and price" do
       expect(rendered).to have_text("With a quantity of: 100")
       expect(rendered).to have_text("With a decoration price of: $1.5")
       expect(rendered).to have_text("1-blue")
       expect(rendered).to have_text("3-green")
       expect(rendered).to have_text("group1")
      end
    end


   context 'new line item group has multiple imprintables' do 
    it 'displays both imprintable prices' do
       expect(rendered).to have_text("With an imprintable price of: $0.5")
       expect(rendered).to have_text("With an imprintable price of: $0.1")
    end     
  end
end
