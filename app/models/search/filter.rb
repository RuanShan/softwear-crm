module Search
  class Filter < ActiveRecord::Base
    belongs_to :filter_holder, polymorphic: true
    belongs_to :filter_type, polymorphic: true

    validates_presence_of :filter_type
    after_destroy :destroy_type

    alias_method :type, :filter_type
    alias_method :type=, :filter_type=

    def respond_to?(*args)
      super || filter_type.respond_to?(*args)
    end

    def method_missing(name, *args, &block)
      return super unless filter_type.respond_to?(name)
      filter_type.send name, *args, &block
    end

    private
    def destroy_type
      filter_type.destroy
    end
  end
end