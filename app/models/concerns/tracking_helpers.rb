module TrackingHelpers
  extend ActiveSupport::Concern

  included do
    include PublicActivity::Model unless ancestors.include? PublicActivity::Model

    class << self
      def activity_key(activity_name)
        "#{name.underscore}.#{activity_name}"
      end

      protected
      def by_current_user
        { owner: ->(controller, record) { controller.current_user if controller } }
      end
      def with_params(*params)
        {params: ->(controller, record) {
            ([{}] + params).combine do |total, entry|
              total.merge case entry
                when Proc
                  hash = entry.call(controller, record)
                  unless hash.is_a? Hash
                    raise "Result of proc must be a hash. Got #{entry.class.name} instead."
                  end
                  hash
                when Hash
                  entry
                else
                  raise "Must be a hash or proc. Got #{entry.class.name} instead."
                end
            end
          }
        }
      end
    end
  end
end