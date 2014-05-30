##
# Injectables are awfully similar to Concerns, except they actually work, and
# are more concise.
# 
# Injectables go in the helpers/injectables folder, and are defined like so:
# 
# -Injectable.TestInjectable do
# -  attr_reader :thing
# -  def do_thing(str)
# -    @thing = "hello "+str
# -  end
# -  def self.static_thing
# -    puts 'static '+@thing
# -  end
# -end
# 
# This defines an Injectable called TestInjectable that any class or module that
# extends Injector can inject with the inject function. (ActiveRecord::Base is
# automatically extended with Injector.)
# 
# -class TestClass
# -  extend Injector
# -  def initialize
# -    @thing = "none"
# -  end
# -  inject TestInjectable
# -end
# 
# This gives the TestClass the do_thing instance method, an attr_reader on 
# @thing, and the static_thing class method as expected.
# 
# There's also options (only 1 for now) you can define with the Injectable:
# -Injectable.TestInjectable track_methods: false do ...
# Will turn off the detault track_methods behavior.
# 
# Additionally, you can change the options when injecting, like:
# -inject TestInjectable, track_methods: false
# 
# You can also namespace these:
# 
# -Injectable.SomeScope.TestInjectable do ...
# 
# Will give you an injectable you can inject with 
# -inject SomeScope.TestInjectable

# Though, "namespacing" these won't do too well if there's already a module 
# of any of the names. I'm guessing it's not worth the effort at this point 
# to make these play nicely with modules.
##
class Injectable
  attr_reader :block
  attr_reader :options

  DEFAULT_OPTIONS = {
    # If true, for each method defined, the injector will also 
    # define a method called :original_<methodname>.
    # Useful if you might want to override but not rewrite 
    # functionality, but could be costly if used a lot.
    track_methods: false
  }

  def initialize(options={}, &block)
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
        if !scope.const_get(name).is_a? Injectable
          raise ArgumentError.new "#{scope.const_get(name).inspect} is not an Injectable."
        else
          return scope.const_get(name)
        end
      end
    end
    options = {}
    options = args.first if args.first && args.first.kind_of?(Hash)

    scope.const_set name, Injectable.new(options, &block)
    scope.const_get name
  end
end