module OrderHelpers
  def visit_edit_order_tab(order, tab_id)
    visit "#{edit_order_path(order)}##{tab_id}"
  end

  def navigate_to_tab(tab_text)
    within('ul.nav-tabs') do
      click_link tab_text
      sleep 2
    end
  end
end
