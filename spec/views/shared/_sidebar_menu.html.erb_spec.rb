require 'spec_helper'

describe 'shared/_sidebar.html.erb', pending: 'waiting on Ricky' do
  context 'viewing the imprintables controller' do
    before(:each) do
      render partial: 'shared/sidebar_menu', locals: {controller_name: 'imprintables'}
    end

    it 'displays imprintables dropdown menu' do
      expect(response).to have_css('li.active ul.visible')
    end

    it 'highlights the active controller' do
      expect(response).to have_css('li.active ul.visible li.active')
    end
  end

  context 'when visiting root path' do
    it 'Only highlights dashboard' do
      render partial: 'shared/sidebar_menu', locals: {controller_name: 'home'}
      expect(response).to_not have_css('li.active')
    end
  end
end
