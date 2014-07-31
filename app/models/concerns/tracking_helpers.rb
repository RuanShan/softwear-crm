module TrackingHelpers
  extend ActiveSupport::Concern

  included do
    include PublicActivity::Model unless ancestors.include? PublicActivity::Model

    class << self
      def activity_key_for(activity_name)
        "#{name.underscore}.#{activity_name}"
      end

      protected
      ### Helper methods for #tracked parameters ###

      # Assign the owner to the current user.
      def by_current_user
        { owner: ->(controller, record) { controller.current_user if controller } }
      end
      # Assign the recipient to either the record's associated order, 
      # or the current order based on the controller.
      def on_order
        { recipient: Proc.new(&TrackingHelpers::Methods.method(:get_order)) }
      end
      # Allows parameters to be applied through (controller, record) procs,
      # or you can just pass one or more hashes.
      def with_params(*params)
        { params: ->(controller, record) {
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

    class Methods
      def self.get_order(controller, record)
        if record.is_a? Order
          record
        elsif record.respond_to?(:order) && record.order
          record.order
        elsif controller
          controller.instance_variable_get :@order
        end
      end
    end
  end
end