require 'spec_helper'

feature 'Imprintables Management' do
  scenario 'A user can see a list of imprintables' do
    visit root_path
    click_link 'imprintables_list_link'
    expect(current_path).to eq(imprintables_path)
    expect(find_by_id('imprintables_list')).to_not be_nil
  end

  feature 'A user can create a new imprintable'
    # navigate to homepage
    # click imprintables link
    # click create new imprintable
    # supply form data
    # submit new imprintable
    # receive confirmation message
    # data reflected in database

  feature 'A user can edit an imprintable'
    # navigate to homepage
    # navigate to imprintables page
    # select an existing imprintable
    # click edit imprintable
    # edit selected imprintable's form data
    # submit form data
    # receive confirmation message
    # updated data reflected in database

  feature 'A user can delete an existing imprintable'
    # navigate to homepage
    # navigate to imprintable page
    # select an existing imprintable
    # delete imprintable
    # receive confirmation message
    # imprintable removed from database

end