module GeneralHelpers
  def with(thing)
    yield thing
  end

  def queries_after(&block)
  	count = 0
  	counter_func = ->(name,started,finished,unique_id,payload) {
  		# puts "#{payload[:name]}:\t#{payload[:sql]}\n\n"
  		count += 1 unless payload[:name].in? %w[ CACHE SCHEMA ]
  	}
  	ActiveSupport::Notifications.subscribed counter_func, "sql.active_record", &block
  	count
  end
end