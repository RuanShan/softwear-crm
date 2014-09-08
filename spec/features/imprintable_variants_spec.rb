require 'spec_helper'
require 'database_cleaner'
include ApplicationHelper

feature 'Imprintable Variant Management', js: true, imprintable_variant_spec: true do
  given!(:valid_user) { create(:alternate_user) }
  given!(:color) { create(:valid_color) }
  given!(:size) { create(:valid_size) }

  before(:each) { login_as(valid_user) }

  context 'There are no imprintable variants' do
    given!(:imprintable) { create(:valid_imprintable) }

    scenario 'A user can create an initial size and color' do
      visit edit_imprintable_path imprintable.id

      select_from_chosen(color.id, from: 'color_ids')
      select_from_chosen(size.id, from: 'size_ids')
      find('#submit_button').click

      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(ImprintableVariant.where(color_id: color.id)).to_not be_nil
      expect(ImprintableVariant.where(size_id: size.id)).to_not be_nil
      expect(ImprintableVariant.where(imprintable_id: imprintable.id)).to_not be_nil
    end
  end

  context 'There is an imprintable invariant' do
    given!(:imprintable_variant) { create(:valid_imprintable_variant) }

    before(:each) { visit edit_imprintable_path imprintable_variant.imprintable.id }

    scenario 'A user can change the weight of a variant' do
      find(:css, 'div.quote-variant-weight input.form-control').set(2)
      click_button 'Update Imprintable'
      expect(page).to have_selector '.modal-content-success', text: 'Imprintable was successfully updated.'
      expect(ImprintableVariant.where(weight: 2)).to_not be_nil
    end

    scenario 'A user can see a grid of imprintable variants' do
      expect(page).to have_css('#imprintable_variants_list')
    end

    scenario 'A user can add a size column', pending: 'Unsure how to select from chosen' do
      select_from_chosen(size.display_value, from: 'size_select_chosen')
      find('#size_button').click
      expect(page).to have_selector 'th', text: size.display_value
    end

    scenario 'A user can add a color row', pending: 'Unsure how to select from chosen' do
      select_from_chosen(color.name, from: 'color-select')
      find('#color_button').click
      expect(page).to have_selector 'th', text: color.name
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
