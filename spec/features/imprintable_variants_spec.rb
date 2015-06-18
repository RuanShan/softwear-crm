require 'spec_helper'
require 'database_cleaner'
include ApplicationHelper

feature 'Imprintable Variant Management', js: true, imprintable_variant_spec: true do
  given!(:valid_user) { create(:alternate_user) }
  given!(:color) { create(:valid_color) }
  given!(:size) { create(:valid_size) }

  before(:each) { login_as(valid_user) }

  context 'There are no imprintable variants' do
    given!(:imprintable) do
      create(
        :valid_imprintable,
        imprintable_variants: [
          create(:valid_imprintable_variant, color: color, size: size),
          create(:valid_imprintable_variant, size: size)
        ]
      )
    end

    scenario 'A user can create an initial size and color', story_692: true do
      visit edit_imprintable_path imprintable.id
      sleep 1
      find('#color-select', visible: false).select color.name
      find('#size-select', visible: false).select "display_value_#{color.name[6]}"
      wait_for_ajax
      find('#submit_button').click
      wait_for_ajax
      expect(page).to have_content 'Imprintable was successfully updated.'
      expect(ImprintableVariant.where(color_id: color.id)).to_not be_nil
      expect(ImprintableVariant.where(size_id: size.id)).to_not be_nil
      expect(ImprintableVariant.where(imprintable_id: imprintable.id)).to_not be_nil
    end
  end

  context 'There is an imprintable variant' do
    given!(:color) { create(:valid_color) }
    given!(:size) { create(:valid_size) }

    given!(:imprintable_variant) do
      create(
        :valid_imprintable_variant,
        color: color, size: size
      )
    end

    before(:each) { visit edit_imprintable_path imprintable_variant.imprintable.id }


    scenario 'A user can see a grid of imprintable variants' do
      expect(page).to have_css('#imprintable_variants_list')
    end

    scenario 'A user can add a size column', story_213: true, story_692: true do
      find('#color-select').select color.name
      click_link 'Add Color'
      find('#size-select').select "display_value_#{color.name[6]}"
      click_link 'Add a size'

      expect(page).to have_selector 'th', text: "display_value_#{color.name[6]}"
      click_button 'Update Imprintable'

      expect(page).to have_selector 'th', text: "display_value_#{color.name[6]}"
    end

    scenario 'A user can add a color row', story_213: true, story_692: true do
      find('#color-select').select color.name
      click_link 'Add Color'
      wait_for_ajax
      expect(page).to have_selector 'th', text: color.name
      click_button 'Update Imprintable'
      wait_for_ajax
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
