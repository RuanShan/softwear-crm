require 'spec_helper'

describe 'orders/_details.html.erb_spec.rb', order_spec: true do
  login_user

  before :each do
  	render partial: 'orders/details', locals: { order: create(:order) }
  end

  it 'should display the commission amount and sales status fields' do
    within_form_for Order do
      expect(rendered).to have_field_for :commission_amount
    end
  end

  it 'should have a save button' do
  	within_form_for Order do
  		expect(rendered).to have_css 'input[type="submit"][value="Save"]'
  	end
  end
end
