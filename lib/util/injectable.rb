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
    @children = {}
    @block = block if block_given?
  end

  def const_defined?(name)
    @children[name] != nil
  end
  def const_get(name)
    @children[name]
  end
  def const_set(name, value)
    @children[name] = value
  end

  def method_missing(name, *args, &block)
    Injectable.send(name, args.first, self, &block)
  end

  def self.method_missing(name, *args, &block)
    scope = args.count > 1 ? args[1] : Object
    if scope.const_defined?(name) && !scope.const_get(name).is_a?(Injectable)
      raise NameError.new "#{name} is already defined as a non-injectable."
    end
    unless block_given?
      if scope.const_defined?(name)
        return scope.const_get(name)
      else
        raise ArgumentError.new "An Injectable is useless without a block!"
      end
    end
    options = {}
    options = args.first if args.first && args.first.kind_of?(Hash)

    scope.const_set name, Injectable.new(options, &block)
  end
end