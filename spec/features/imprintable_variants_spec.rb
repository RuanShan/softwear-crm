require 'spec_helper'
include ApplicationHelper

feature 'Imprintable Variant Management', imprintable_variant_spec: true do
  given!(:valid_user) { create(:alternate_user) }
  before (:each) do
    login_as(valid_user)
  end

  context 'There are no imprintable variants' do
    scenario 'A user can create an initial size and color'
  end

  let!(:imprintable_variant) { create(:valid_imprintable_variant) }
  let!(:imprintable) { create(:valid_imprintable) }

  before(:each) do
    create(:valid_color)
    create(:valid_size)
    visit imprintables_path
    find("tr#imprintable_#{imprintable.id} a[data-action='edit']").click
  end

  scenario 'A user can see a grid of imprintable variants' do
    expect(page).to have_css('#imprintable_variants_list')
  end

  scenario 'A user can add a size column'

  scenario 'A user can add a color row'

  scenario 'A user can toggle a column', js: true do
    find('#col_plus_1').click
    expect(page).to have_css('.fa-check')
  end

  scenario 'A user can toggle a cell', js: true do
    first('.cell').click
    expect(page).to have_css('.fa-check')
  end

  scenario 'A user can toggle a row', js: true do
    find('#row_plus_1').click
    expect(page).to have_css('.fa-check')
  end
end