module Injector
  def inject(injectable)
    unless injectable.is_a? Injectable
      raise ArgumentError.new "#{injectable.inspect} is not injectable."
    end
    if injectable.block == nil
      raise ArgumentError.new "#{injectable.inspect} has no block."
    end
    tracked_methods = injectable.options[:track_methods]

    # if we're tracking all methods, record the methods added
    before_methods = self.instance_methods if tracked_methods == true
    self.class_eval &injectable.block
    after_methods = self.instance_methods if tracked_methods == true
    
    if tracked_methods
      tracked_methods = after_methods - before_methods if tracked_methods == true
      
      tracked_methods.each do |m|
        alias_method "original_#{m}".to_sym, m
      end
    end
  end
end

ActiveRecord::Base.instance_eval do
  extend Injector
end
