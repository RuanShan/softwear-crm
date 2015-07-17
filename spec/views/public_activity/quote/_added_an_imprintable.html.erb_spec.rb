require 'spec_helper'

  describe 'public_activity/quote/_added_an_imprintable.html.erb' do
    let!(:activity1) { build_stubbed(:quote_activity_add_imprintable) } 
    let!(:imprint) { build_stubbed(:valid_imprint) }
    let!(:imprintable) { build_stubbed(:valid_imprintable) }
    let!(:job) { build_stubbed(:job) }

    before(:each) do
      existence = double("receiver")
      existence.stub(:exists?) { true }

      allow(ImprintableVariant).to receive(:exists?).and_return(true)
      allow(ImprintableVariant).to receive(:find).and_return(instance_double("ImprintableVariant", imprintable: imprintable ))
      allow(Job).to receive(:exists?).and_return(true)
      allow(Job).to receive(:find).and_return(job)

      render partial: 'public_activity/quote/added_an_imprintable', locals: {activity: activity1 }
    end 

    context 'new imprintable added to quote' do 
      it 'has appropriate fields listed in the timeline: '\
       "quantity, decoration price, imprintable price,"\
      "tier, and group_id" do

       expect(rendered).to have_text("#{imprintable.name}") 
       expect(rendered).to have_text("Decoration: $1.33")
       expect(rendered).to have_text("Imp. Price: $0.70")
       expect(rendered).to have_text("Tier: Good")
       expect(rendered).to have_text("Group: #{job.name}")
       expect(rendered).to have_text("Quantity: 130")
    end
  end
end
