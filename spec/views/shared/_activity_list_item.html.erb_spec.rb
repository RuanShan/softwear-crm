require 'spec_helper'

describe 'shared/_activity_list_item.html.erb' do
  let!(:activity1) { create(:quote_activity_update) } 
  let!(:activity2) { create(:quote_activity_line_item_update) }   

  before(:each) do 
      allow(view).to receive(:render_activity).and_return("")
      render partial: 'shared/activity_list_item', locals: {activity: activity1 }
  end 

  it 'has the crm user who made the change' do 
      expect(rendered).to have_css("a[href^='/users/']")  
  end

  it 'has a timestamp' do 
      expect(rendered).to have_css(".time")
  end
end
