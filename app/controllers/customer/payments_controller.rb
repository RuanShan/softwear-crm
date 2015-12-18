module Customer
  class PaymentsController < BaseController
    belongs_to :order, optional: true
    defaults route_prefix: 'customer'

    def create
      super
    rescue Payment::PaymentError => e
      # TODO inform user and send email
    end
  end
end
