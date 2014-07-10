module TrackingHelpers
  extend ActiveSupport::Concern

  included do
    include PublicActivity::Model unless ancestors.include? PublicActivity::Model

    class << self
      def by_current_user
        { owner: ->(controller, model) { controller.current_user if controller }}
      end
    end
  end
end