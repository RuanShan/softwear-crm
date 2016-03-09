require 'spec_helper'
include LineItemHelpers

feature 'Costs Management', js: true do
  let!(:order_1) { create(:order_with_job) }
  let!(:order_2) { create(:order_with_job) }
  let(:job_1)    { order_1.jobs.first }
  let(:job_2)    { order_2.jobs.first }

  let!(:white) { create(:valid_color, name: 'white') }
  let!(:shirt) { create(:valid_imprintable) }
  let!(:blue) { create(:valid_color, name: 'blue') }
  let!(:pants) { create(:valid_imprintable) }

  make_variants :white, :shirt, [:M, :S, :L], lazy: true
  make_variants :blue,  :pants, [:M, :S, :L], lazy: true

  background :each do
    job_1.line_items = [white_shirt_m_item, white_shirt_s_item, white_shirt_l_item]
    job_2.line_items = [blue_pants_m_item, blue_pants_s_item, blue_pants_l_item]
  end

  given!(:valid_user) { create(:user) }
  before(:each) do
    sign_in_as valid_user
  end

  scenario 'A user can add costs to line items that lack them' do
    visit costs_imprintables_path
    inputs = all('input[type=text]')

    inputs[0].set '12.00'
    inputs[1].set '10.00'

    click_button 'Submit'

    expect(Cost.where(amount: 12)).to exist
    expect(Cost.where(amount: 10)).to exist
  end
end
