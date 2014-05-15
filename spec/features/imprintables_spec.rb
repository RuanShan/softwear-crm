require 'spec_helper'


feature 'Imprintables Management' do

  let!(:imprintable) { create(:valid_imprintable)}


  scenario 'A user can see a list of imprintables' do
    visit root_path
    click_link 'imprintables_list_link'
    expect(current_path).to eq(imprintables_path)
    expect(find_by_id('imprintables_list')).to_not be_nil
  end

  scenario 'A user can create a new imprintable' do
    visit root_path
    click_link 'imprintables_list_link'
    click_link('new_imprintable_link')
    fill_in 'imprintable_name', :with => 'Sample Name'
    fill_in 'imprintable_catalog_number', :with => '42'
    fill_in 'imprintable_description', :with => 'Sample description'
    click_button('Create Imprintable')
    expect(current_path).to eq(imprintables_index_path)
    expect(find_by_id('notice')).to_not be_nil
    expect(Imprintable.find_by name: 'Sample Name')
  end

  scenario 'A user can edit an existing imprintable' do
    visit root_path
    click_link 'imprintables_list_link'
    click_button  'edit_imprintable_link'
    # edit selected imprintable's form data
    fill_in 'imprintable_name', :with => 'Edited Name'
    # submit form data
    # receive confirmation message
    # updated data reflected in database
  end

  @wip
  scenario 'A user can delete an existing imprintable' do
    # navigate to homepage
    # navigate to imprintable page
    # select an existing imprintable
    # delete imprintable
    # receive confirmation message
    # imprintable removed from database
  end

end