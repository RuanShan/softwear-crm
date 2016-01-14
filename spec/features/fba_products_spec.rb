require 'spec_helper'

feature 'FBA Products management', js: true do
  given!(:fba_job_template) { create(:fba_job_template_with_imprint) }
  given!(:imprintable_variant) { create(:associated_imprintable_variant) }
  given!(:imprintable) { imprintable_variant.imprintable }
  given!(:imprintable_2) { create(:associated_imprintable) }

  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as(valid_user) }

  scenario 'A user can create a new FBA Product', new: true do
    visit new_fba_product_path
    fill_in 'Name', with: 'Baberaham Lincoln'
    fill_in 'Master SKU', with: 'misc_baberah'

    click_link 'Add Child SKU'

    find('.fba-sku-name').set '0-misc_baberah-1030101009'
    find('.fba-sku-brand-id').set imprintable.brand.name
    find('.fba-sku-style-catalog-no').set imprintable.style_catalog_no
    find('.fba-sku-color').set imprintable_variant.color.name
    find('.fba-sku-size').set imprintable_variant.size.name
    find('.fba-sku-job-template').select fba_job_template.name

    click_button 'Create FBA Product'
  end
end
