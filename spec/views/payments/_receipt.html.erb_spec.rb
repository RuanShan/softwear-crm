require 'spec_helper'

describe 'payments/_receipt', type: :view, js: true do
 
  context 'Given a payment with an order' do
    
    before { 
      render 'payments/receipt', payment: order_payment, order: order_payment.order 
    }

    let!(:order_payment) { create(:valid_payment) }

    it 'should display the customer information and the  information' do
      #if payment is from an order, it will have the order's name
      expect(rendered).to have_text("#{order_payment.order.name}")
    end
  end

  context 'Given a retail payment' do
    
    before { 
      render 'payments/receipt', payment: retail_payment, order: retail_payment.order 
    }

    let!(:retail_payment) { create(:retail_payment) }

    it 'should display it as walkin payment' do
      #if retail, order name will be walk in retail
      expect(rendered).to have_text("Walk-in Retail")
    end
  end
end
