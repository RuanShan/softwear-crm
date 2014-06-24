module SunspotHelpers
  def solr_running?
    File.exists? Rails.root.join('solr', 'pids', 'test', 'sunspot-solr-test.pid').to_s
  end

  # Pass false if you want solr to not output to console
  def start_solr(*do_output)
    solr_cmd 'start', do_output.first == false
  end
  def stop_solr(*do_output)
    solr_cmd 'stop', do_output.first == false
  end
  def reindex_solr(*do_output)
    solr_cmd 'reindex', do_output.first == false
  end

  def wait_for_solr(*timeout_seconds)
    Timeout::timeout(timeout_seconds.first || 5) do
      while true
        begin
          ping_solr
          break
        rescue Errno::ECONNREFUSED
          sleep 0.3
        end
      end
    end
    sleep 0.3
  end

  def ping_solr
    Net::HTTP.get URI "#{Sunspot.config.solr.url}/admin/ping"
  end

  private
  def solr_cmd(command, supress_output)
    actual_command = "rake sunspot:solr:#{command} RAILS_ENV=test"
    if (supress_output)
      %x(#{actual_command}) else system(actual_command)
    end
  end
end