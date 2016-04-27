module Retry
  def retry_n_times(n, options = {})
    delay = options[:delay] || 0
    retry_count = 0

    begin
      yield
    rescue StandardError => _
      retry_count += 1

      if retry_count > n
        raise
      else
        retry
      end
    end
  end
end