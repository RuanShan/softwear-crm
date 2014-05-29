class Injectable
  attr_reader :block
  attr_reader :options

  DEFAULT_OPTIONS = {
    # If true, for each method defined, the injector will also 
    # define a method called :original_<methodname>.
    # Useful if you might want to override but not rewrite 
    # functionality, but could be costly if used a lot.
    track_methods: true
  }

  def initialize(options, &block)
    @options = DEFAULT_OPTIONS.merge options
    @block = block
  end

  def self.method_missing(name, *args, &block)
    if Object.const_defined?(name) && !Object.const_get(name).is_a?(Injectable)
      raise NameError.new "#{name} is already defined as a non-injectable."
    end
    unless block_given?
      raise ArgumentError.new "An Injectable is useless without a block!"
    end
    options = {}
    options = args.first if args.first && args.first.kind_of?(Hash)

    Object.const_set name, Injectable.new(options, &block)
  end
end