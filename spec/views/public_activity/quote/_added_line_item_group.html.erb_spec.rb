require 'spec_helper'

  describe 'public_activity/quote/_added_line_item_group.html.erb' do
    let!(:activity1) { build_stubbed(:quote_activity_line_item_group) } 
    let!(:imprint) { build_stubbed(:valid_imprint) }
    let!(:imprintable) { build_stubbed(:valid_imprintable) }

    before(:each) do
      existence = double("receiver")
      existence.stub(:exists?) { true }

      allow_any_instance_of(Quote).to receive(:imprints).and_return(existence)
      allow(Imprint).to receive(:find).and_return(imprint)
     
      allow(ImprintableVariant).to receive(:exists?).and_return(true)
      allow(ImprintableVariant).to receive(:find).and_return(instance_double("ImprintableVariant", imprintable: imprintable ))

      render partial: 'public_activity/quote/added_line_item_group', locals: {activity: activity1 }
    end 

    context 'new line item group added to quote' do 
      it "displays the imprints names, locations and descriptions "\
         "and it displays line item quantity, decoration price and "\
         "group name. It also displays each imprintables name and price" do
       expect(rendered).to have_text("Quantity: 100")
       expect(rendered).to have_text("Decoration Price: $1.50")
       expect(rendered).to have_text(imprint.name)
       expect(rendered).to have_text(imprint.description) 
           
      end
    end


   context 'new line item group has multiple imprintables' do 
    it 'displays both imprintable prices' do
       expect(rendered).to have_text("Price: $2.00")
       expect(rendered).to have_text("Price: $1.60")
    end     
  end
end
