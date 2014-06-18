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

  RSpec::Matchers.define :inherit_from do |inherited|
    match do |subject|
      clazz = nil
      parent_class = nil
      if subject.respond_to? :ancestors
        clazz = subject
      else
        clazz = subject.class
      end
      if inherited.is_a?(Symbol) || inherited.is_a?(String)
        parent_class = Kernel.const_get(inherited)
      else
        parent_class = inherited
      end
      clazz.ancestors.include? parent_class
    end
    failure_message do |subject|
      "The ancestors of #{subject} do not include #{inherited.inspect}"
    end
  end
end