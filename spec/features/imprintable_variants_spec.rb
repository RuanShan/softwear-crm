require 'spec_helper'
require 'database_cleaner'
include ApplicationHelper

feature 'Imprintable Variant Management', imprintable_variant_spec: true do
  given!(:valid_user) { create(:alternate_user) }
  before (:each) do
    login_as(valid_user)
  end

  given!(:color) { create(:valid_color) }
  given!(:size) { create(:valid_size) }

  context 'There are no imprintable variants' do
    given!(:imprintable) { create(:valid_imprintable) }
    scenario 'A user can create an initial size and color' do
      visit edit_imprintable_path imprintable.id
      find(:css, "#color_ids_[value='#{color.id}']").set(true)
      find(:css, "#size_ids_[value='#{size.id}']").set(true)
      find('#submit_button').click
      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(ImprintableVariant.find_by(imprintable_id: "#{imprintable.id}")).to_not be_nil
    end
  end

  context 'There is an imprintable invariant', js: true do

    given!(:imprintable_variant) { create(:valid_imprintable_variant) }

    before(:each) do
      visit edit_imprintable_path imprintable_variant.imprintable.id
    end

    scenario 'A user can see a grid of imprintable variants' do
      expect(page).to have_css('#imprintable_variants_list')
    end

    scenario 'A user can add a size column' do
      selected = find('#size_select').find("option[value='#{size.id}']").text
      find('#size_select').find("option[value='#{size.id}']").click
      find('#size_button').click
      expect(page).to have_selector 'th', text: selected
    end

    scenario 'A user can add a color row' do
      selected = find('#color_select').find("option[value='#{color.id}']").text
      find('#color_select').find("option[value='#{color.id}']").click
      find('#color_button').click
      expect(page).to have_selector 'th', text: selected
    end

    scenario 'A user can toggle a column' do
      expect(page).to have_css('i.fa-check#image_1_1')
      find('#col_minus_1').click
      expect(page).to have_css('i.fa-times#image_1_1')
    end

    scenario 'A user can toggle a cell' do
      expect(page).to have_css('i.fa-check#image_1_1')
      first('i.fa.fa-minus.cell').click
      expect(page).to have_css('i.fa-times#image_1_1')
    end

    scenario 'A user can toggle a row' do
      expect(page).to have_css('i.fa-check#image_1_1')
      find('#row_minus_1').click
      expect(page).to have_css('i.fa-times#image_1_1')
    end
  end
end
