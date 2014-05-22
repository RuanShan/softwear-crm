require 'spec_helper'

describe 'timeline/show.html.erb' do

  it 'renders a timeline' do
    assign(:order, Order.new)
    render
    expect(rendered).to include('Timeline')
  end
end