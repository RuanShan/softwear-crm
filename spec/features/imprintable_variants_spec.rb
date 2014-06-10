require 'spec_helper'
require 'database_cleaner'
include ApplicationHelper

feature 'Imprintable Variant Management', imprintable_variant_spec: true do
  given!(:valid_user) { create(:alternate_user) }
  before (:each) do
    login_as(valid_user)
  end

  let!(:color) { create(:valid_color) }
  let!(:size) { create(:valid_size) }

  context 'There are no imprintable variants' do
    let!(:imprintable) { create(:valid_imprintable) }
    scenario 'A user can create an initial size and color' do
      visit imprintables_path
      find("tr#imprintable_#{imprintable.id} a[data-action='edit']").click
      find(:css, "#color_ids_[value='#{color.id}']").set(true)
      find(:css, "#size_ids_[value='#{size.id}']").set(true)
      find('#submit_button').click
      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(ImprintableVariant.find_by(imprintable_id: "#{imprintable.id}")).to_not be_nil
    end
  end

  context 'There is an imprintable invariant', js: true do

    DatabaseCleaner.clean

    let!(:imprintable_variant) { create(:valid_imprintable_variant) }

    before(:each) do
      visit imprintables_path
      find("tr#imprintable_#{imprintable_variant.imprintable_id} a[data-action='edit']").click
    end

    scenario 'A user can see a grid of imprintable variants' do
      expect(page).to have_css('#imprintable_variants_list')
    end

    scenario 'A user can add a size column' do
      find('#size_button').click
      sleep 1
      find('#size_select').find("option[value='#{size.id}']").click
      sleep 1
      expect(page).to have_css('#col_2')
    end

    scenario 'A user can add a color row' do
      find('#color_button').click
      sleep 1
      find('#color_select').find("option[value='#{color.id}']").click
      sleep 1
      expect(page).to have_css('#row_2')
    end

    scenario 'A user can toggle a column' do
      find('#col_plus_1').click
      sleep 1
      expect(page).to have_css('.fa-check')
    end

    scenario 'A user can toggle a cell' do
      first('.cell').click
      sleep 1
      expect(page).to have_css('.fa-check')
    end

    scenario 'A user can toggle a row' do
      find('#row_plus_1').click
      sleep 1
      expect(page).to have_css('.fa-check')
    end
  end
end
