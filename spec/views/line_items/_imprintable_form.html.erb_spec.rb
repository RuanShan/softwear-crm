require 'spec_helper'

describe 'line_items/_imprintable_form.html.erb', line_item_spec: true do
  it 'renders 4 select-levels for the JS magic to take place' do
    render partial: 'line_items/imprintable_form', locals: {job: create(:job), line_item: LineItem.new}
    4.times do |n|
      expect(rendered).to have_css ".select-level[data-level='#{n+1}']"
    end
  end
end