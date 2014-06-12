module WaitForAjax
  def wait_for_ajax
    wait_for_jquery
    Timeout.timeout(Capybara.default_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end

  def wait_for_redirect
    original_url = current_path
    until current_path != original_url
      sleep(0.1)
    end
  end

  def wait_for_jquery
    until page.evaluate_script('jQuery.active') == 0
      sleep(0.1)
    end
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end
