module WaitForAjax
  def wait_for_ajax
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
  		sleep(1)
  	end
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end