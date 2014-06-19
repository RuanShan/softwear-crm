module Search
  module FilterType
    extend ActiveSupport::Concern

    included do
      has_one :filter, as: :filter_type
    end

    def method_missing(name, *args, &block)
      filter.send name, *args, &block
    end
  end
end