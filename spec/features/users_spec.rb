require 'spec_helper'

feature 'Users', user_spec: true, js: true do
  given!(:valid_user) { create(:user) }

  # TODO...

  context 'with valid credentials', story_692: true do
  end

  context 'logged in' do
  end
end
