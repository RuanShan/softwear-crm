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

  def clear_solr
    data_path = Rails.root.join('solr', 'test', 'data')
    FileUtils.rm_rf data_path.to_s
  end

  def wait_for_solr(*timeout_seconds)
    Timeout::timeout(timeout_seconds.first || 5) do
      while true
        begin
          ping_solr
          break
        rescue Errno::ECONNREFUSED
          sleep 0.1
        end
      end
    end
  end

  def ping_solr
    Net::HTTP.get URI "#{Sunspot.config.solr.url}/admin/ping"
  end

  # For some reason, Solr likes to occasionally return 
  # empty arrays when testing. This deals with that.
  def assure_solr_search(*args)
    options = args.first || {}
    results = []
    Timeout::timeout(10) do
      while if options[:expect]
              results.count != options[:expect]
            else results.empty? end
        results = yield
      end
    end
    results
  end

  private
  def solr_cmd(command, supress_output)
    actual_command = "rake sunspot:solr:#{command} RAILS_ENV=test"
    if (supress_output)
      %x(#{actual_command}) else system(actual_command)
    end
  end
end