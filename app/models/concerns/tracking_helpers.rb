module TrackingHelpers
  extend ActiveSupport::Concern

  class Methods
    def self.get_order(controller, record)
      begin
      if record.is_a? Order
        record
      elsif record.respond_to?(:jobbable) && record.jobbable_type == 'Order'
        record.jobbable
      elsif record.respond_to?(:order) && record.order
        record.order
      elsif controller
        controller.instance_variable_get :@order
      end

      rescue ActiveRecord::HasManyThroughSourceAssociationNotFoundError => _e
        nil
      end
    end
  end


  included do
    include PublicActivity::Model unless ancestors.include? PublicActivity::Model

    class << self
      def activity_key_for(activity_name)
        "#{name.underscore}.#{activity_name}"
      end

      def without_tracking
        public_activity_off
        yield
      ensure
        public_activity_on
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
        { recipient: TrackingHelpers::Methods.method(:get_order).to_proc }
      end
      # Allows parameters to be applied through (controller, record) procs,
      # or you can just pass one or more hashes.
      # TODO this does not work and is not used.
      def with_params(*params)
        {
          params: lambda do |controller, record|
            params.reduce({}) do |total, entry|
              total.merge case entry
                when Proc, Method
                  hash = entry.call(controller, record)
                  unless hash.is_a? Hash
                    raise "Result of proc must be a hash. "\
                          "Got #{entry.class.name} instead."
                  end
                  hash
                when Hash
                  entry
                when Symbol, String
                  record.send(entry, controller)
                else
                  raise "Must be a hash or proc. "\
                        "Got #{entry.class.name} instead."
                end
            end
          end
        }
      end

      def is_activity_recipient
        define_method :all_activities do
          PublicActivity::Activity.where( %{
            (
              activities.recipient_type = ? AND activities.recipient_id = ?
            ) OR
            (
              activities.trackable_type = ? AND activities.trackable_id = ?
            )
          }, *([self.class.name, self.id] * 2) ).order('created_at DESC')
        end
      end
    end

  end
end
