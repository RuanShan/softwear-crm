require 'spec_helper'
include LineItemHelpers

feature 'FBA Products management', js: true do
  given!(:fba_job_template) { create(:fba_job_template_with_imprint) }

  given!(:shirt) { create(:associated_imprintable) }
  given!(:sweater) { create(:associated_imprintable) }

  given!(:red) { create(:valid_color, name: 'Red') }
  given!(:blue) { create(:valid_color, name: 'Blue') }

  make_variants :red,  :shirt, [:S, :M, :L],   not: %i(line_item job)
  make_variants :blue, :shirt, [:S, :M, :L],   not: %i(line_item job)
  make_variants :red,  :sweater, [:S, :M, :L], not: %i(line_item job)
  make_variants :blue, :sweater, [:S, :M, :L], not: %i(line_item job)

  given(:fba_product) { create(:fba_product, fba_skus: [build(:fba_sku, imprintable_variant: red_shirt_s)]) }

  given!(:valid_user) { create(:alternate_user) }
  background(:each) { login_as(valid_user) }

  scenario 'A user can create a new FBA Product', new: true do
    visit new_fba_product_path
    fill_in 'Name', with: 'Baberaham Lincoln'
    fill_in 'Master SKU', with: 'misc_baberah'

    click_link 'Add Child SKU'

    find('.fba-sku-sku').set '0-misc_baberah-1030101009'

    select2 shirt.brand.name,       from: '.fba-sku-brand'
    sleep 1 if ci?
    select2 shirt.style_catalog_no, from: '.fba-sku-style'
    sleep 1 if ci?
    select2 red.name,               from: '.fba-sku-color'
    sleep 1 if ci?
    select2 size_s.display_value,   from: '.fba-sku-size'
    sleep 1 if ci?
    select2 fba_job_template.name,  from: '.fba-sku-job-template'
    sleep 1 if ci?

    click_button 'Create FBA Product'

    expect(page).to have_content 'successfully created'

    fba_product = FbaProduct.where(name: 'Baberaham Lincoln', sku: 'misc_baberah')
    expect(fba_product).to exist
    expect(fba_product.first.fba_skus.where(sku: '0-misc_baberah-1030101009', imprintable_variant_id: red_shirt_s.id)).to exist
  end

  scenario 'A user can create a new FBA Product with multiple child skus', new: true do
    visit new_fba_product_path
    fill_in 'Name', with: 'Baberaham Lincoln'
    fill_in 'Master SKU', with: 'misc_baberah'

    click_link 'Add Child SKU'

    find('.fba-sku-sku').set '0-misc_baberah-1030101009'

    select2 shirt.brand.name,       from: '.fba-sku-brand'
    sleep 1 if ci?
    select2 shirt.style_catalog_no, from: '.fba-sku-style'
    sleep 1 if ci?
    select2 red.name,               from: '.fba-sku-color'
    sleep 1 if ci?
    select2 size_s.display_value,   from: '.fba-sku-size'
    sleep 1 if ci?
    select2 fba_job_template.name,  from: '.fba-sku-job-template'
    sleep 1 if ci?

    click_link 'Add Child SKU'
    sleep 1 if ci?

    within all('.fba-sku-fields').last do
      find('.fba-sku-sku').set '0-misc_baberah-1030101009'

      select2 sweater.brand.name,       from: '.fba-sku-brand'
      select2 sweater.style_catalog_no, from: '.fba-sku-style'
      select2 blue.name,                from: '.fba-sku-color'
      select2 size_s.display_value,     from: '.fba-sku-size'
      select2 fba_job_template.name,    from: '.fba-sku-job-template'
    end

    click_button 'Create FBA Product'
    sleep 1 if ci?

    expect(page).to have_content 'successfully created'

    fba_product = FbaProduct.where(name: 'Baberaham Lincoln', sku: 'misc_baberah')
    expect(fba_product).to exist
    expect(fba_product.first.fba_skus.size).to eq 2
    expect(fba_product.first.fba_skus.where(sku: '0-misc_baberah-1030101009', imprintable_variant_id: red_shirt_s.id)).to exist
    expect(fba_product.first.fba_skus.where(sku: '0-misc_baberah-1030101009', imprintable_variant_id: blue_sweater_s.id)).to exist
  end

  scenario 'Adding a sku will copy the values from the previous sku if possible', new: true, copy: true do
    visit new_fba_product_path
    fill_in 'Name', with: 'Baberaham Lincoln'
    fill_in 'Master SKU', with: 'misc_baberah'

    click_link 'Add Child SKU'

    find('.fba-sku-sku').set '0-misc_baberah-1030101009'

    select2 shirt.brand.name,       from: '.fba-sku-brand'
    sleep 1 if ci?
    select2 shirt.style_catalog_no, from: '.fba-sku-style'
    sleep 1 if ci?
    select2 red.name,               from: '.fba-sku-color'
    sleep 1 if ci?
    select2 size_s.display_value,   from: '.fba-sku-size'
    sleep 1 if ci?
    select2 fba_job_template.name,  from: '.fba-sku-job-template'
    sleep 1 if ci?

    click_link 'Add Child SKU'

    within all('.fba-sku-fields').last do
      find('.fba-sku-sku').set '0-misc_baberah-1030101007'

      select2 size_m.display_value,  from: '.fba-sku-size'
      select2 fba_job_template.name, from: '.fba-sku-job-template'
    end

    click_button 'Create FBA Product'

    expect(page).to have_content 'successfully created'

    fba_product = FbaProduct.where(name: 'Baberaham Lincoln', sku: 'misc_baberah')
    expect(fba_product).to exist
    expect(fba_product.first.fba_skus.size).to eq 2
    expect(fba_product.first.fba_skus.where(sku: '0-misc_baberah-1030101009', imprintable_variant_id: red_shirt_s.id)).to exist
    expect(fba_product.first.fba_skus.where(sku: '0-misc_baberah-1030101007', imprintable_variant_id: red_shirt_m.id)).to exist
  end

  scenario 'Adding a sku will copy valid sku formats with the size replaced with xx', xx: true, new: true, copy: true do
    visit new_fba_product_path
    fill_in 'Name', with: 'Baberaham Lincoln'
    fill_in 'Master SKU', with: 'misc_baberah'

    click_link 'Add Child SKU'

    find('.fba-sku-sku').set '0-misc_baberah-1030101009'

    select2 shirt.brand.name,       from: '.fba-sku-brand'
    sleep 1 if ci?
    select2 shirt.style_catalog_no, from: '.fba-sku-style'
    sleep 1 if ci?
    select2 red.name,               from: '.fba-sku-color'
    sleep 1 if ci?
    select2 size_s.display_value,   from: '.fba-sku-size'
    sleep 1 if ci?
    select2 fba_job_template.name,  from: '.fba-sku-job-template'
    sleep 1 if ci?

    click_link 'Add Child SKU'

    within all('.fba-sku-fields').last do
      select2 size_m.display_value,  from: '.fba-sku-size'
      select2 fba_job_template.name, from: '.fba-sku-job-template'
    end

    click_button 'Create FBA Product'

    expect(page).to have_content 'successfully created'

    fba_product = FbaProduct.where(name: 'Baberaham Lincoln', sku: 'misc_baberah')
    expect(fba_product).to exist
    expect(fba_product.first.fba_skus.size).to eq 2
    expect(fba_product.first.fba_skus.where(sku: '0-misc_baberah-1030101009', imprintable_variant_id: red_shirt_s.id)).to exist
    expect(fba_product.first.fba_skus.where(sku: '0-misc_baberah-10301__009', imprintable_variant_id: red_shirt_m.id)).to exist
  end

  scenario 'Adding a valid sku pre-populates the imprintable variant fields', new: true, prepopulate: true do
    shirt.update_column  :sku, 3333
    size_s.update_column :sku, 11
    red.update_column    :sku, 222

    visit new_fba_product_path
    fill_in 'Name', with: 'Baberaham Lincoln'
    fill_in 'Master SKU', with: 'misc_baberah'

    click_link 'Add Child SKU'

    find('.fba-sku-sku').set '0-misc_baberah-0333311222'
    select2 fba_job_template.name,    from: '.fba-sku-job-template'

    click_button 'Create FBA Product'

    expect(page).to have_content 'successfully created'

    fba_product = FbaProduct.where(name: 'Baberaham Lincoln', sku: 'misc_baberah')
    expect(fba_product).to exist
    expect(fba_product.first.fba_skus.size).to eq 1
    expect(fba_product.first.fba_skus.where(sku: '0-misc_baberah-0333311222', imprintable_variant_id: red_shirt_s.id)).to exist
  end

  scenario 'A user can edit just the size of an existing FBA Product sku', edit: true do
    visit edit_fba_product_path(fba_product)

    select2 size_l.display_value, from: '.fba-sku-size'
    click_button 'Update FBA Product'

    expect(page).to have_content 'successfully updated'
    expect(fba_product.reload.fba_skus.first.imprintable_variant_id).to eq red_shirt_l.id
  end

  scenario 'A user can edit the color and size of an existing FBA Product sku', edit: true do
    visit edit_fba_product_path(fba_product)

    select2 blue.name,            from: '.fba-sku-color'
    select2 size_m.display_value, from: '.fba-sku-size'
    click_button 'Update FBA Product'

    expect(page).to have_content 'successfully updated'
    expect(fba_product.reload.fba_skus.first.imprintable_variant_id).to eq blue_shirt_m.id
  end

  scenario 'A user can change the whole imprintable variant of an existing sku', edit: true do
    visit edit_fba_product_path(fba_product)

    select2 sweater.brand.name,       from: '.fba-sku-brand'
    select2 sweater.style_catalog_no, from: '.fba-sku-style'
    select2 blue.name,                from: '.fba-sku-color'
    select2 size_s.display_value,     from: '.fba-sku-size'
    select2 fba_job_template.name,    from: '.fba-sku-job-template'
    click_button 'Update FBA Product'

    expect(page).to have_content 'successfully updated'
    expect(fba_product.reload.fba_skus.first.imprintable_variant_id).to eq blue_sweater_s.id
  end

  scenario 'A user can add an additional fba sku to a product', edit: true do
    visit edit_fba_product_path(fba_product)

    click_link 'Add Child SKU'

    within all('.fba-sku-fields').last do
      find('.fba-sku-sku').set '0-misc_baberah-1030101009'

      select2 sweater.brand.name,       from: '.fba-sku-brand'
      select2 sweater.style_catalog_no, from: '.fba-sku-style'
      select2 blue.name,                from: '.fba-sku-color'
      select2 size_s.display_value,     from: '.fba-sku-size'
      select2 fba_job_template.name,    from: '.fba-sku-job-template'
    end

    click_button 'Update FBA Product'

    expect(page).to have_content 'successfully updated'
    expect(fba_product.reload.fba_skus.size).to eq 2
    expect(fba_product.fba_skus.last.imprintable_variant_id).to eq blue_sweater_s.id
  end

  scenario 'A user can add an additional fba sku to a product and change the size of the original one', bugfix: true, edit: true do
    visit edit_fba_product_path(fba_product)

    click_link 'Add Child SKU'

    within all('.fba-sku-fields').last do
      find('.fba-sku-sku').set '0-misc_baberah-1030101009'

      select2 sweater.brand.name,       from: '.fba-sku-brand'
      select2 sweater.style_catalog_no, from: '.fba-sku-style'
      select2 blue.name,                from: '.fba-sku-color'
      select2 size_s.display_value,     from: '.fba-sku-size'
      select2 fba_job_template.name,    from: '.fba-sku-job-template'
    end

    within all('.fba-sku-fields').first do
      select2 size_l.display_value, from: '.fba-sku-size'
    end

    click_button 'Update FBA Product'

    expect(page).to have_content 'successfully updated'
    expect(fba_product.reload.fba_skus.size).to eq 2
    expect(fba_product.fba_skus.last.imprintable_variant_id).to eq blue_sweater_s.id
    expect(fba_product.fba_skus.first.imprintable_variant_id).to eq red_shirt_l.id
  end
end
