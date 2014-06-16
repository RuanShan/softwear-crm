module WaitForAjax
  def wait_for_ajax
    begin
      Timeout.timeout(Capybara.default_wait_time) do
        wait_for_jquery
        loop until finished_all_ajax_requests?
      end
    rescue
      sleep 0.1
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
      # puts "Page.evaluate is #{page.evaluate_script('jQuery.active')}"
      sleep(0.1)
    end
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end