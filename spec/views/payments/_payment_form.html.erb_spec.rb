require 'spec_helper'

describe "payments/_payment_form", type: :view do
  let(:payment) { Payment.new }
  let(:order) { create(:order) }
  let(:user) { create(:user) }
  
  before(:each) do
    assign(:payment, payment)
    assign(:order, order)
    assign(:current_user, user)
    render 'payments/payment_form', payment_method: payment_method
  end

  context 'for every payment' do 
    let(:payment_method) { Payment::VALID_PAYMENT_METHODS.key('Cash') }
    
    it 'has a hidden field for method, order, and salesperson, '\
       'a store select, and an amount' do
      expect(rendered).to have_selector('input[type=hidden]#payment_salesperson_id') 
      expect(rendered).to have_selector('input[type=hidden]#payment_order_id') 
      expect(rendered).to have_selector('input[type=hidden]#payment_payment_method') 
      expect(rendered).to have_selector('select#payment_store_id') 
      expect(rendered).to have_selector('input#payment_amount') 
    end
  end
  
  context 'for check payments' do 
    let(:payment_method) { Payment::VALID_PAYMENT_METHODS.key('Check') }
    
    it 'has a field for drivers license, and phone number' do
      expect(rendered).to have_selector('input#payment_check_dl_no') 
      expect(rendered).to have_selector('input#payment_check_phone_no') 
    end
  end
  
  context 'for PayPal' do 
    let(:payment_method) { Payment::VALID_PAYMENT_METHODS.key('PayPal') }
    
    it 'has a field for paypal transaction id' do
      expect(rendered).to have_selector('input#payment_pp_transaction_id') 
    end
  end
  
  context 'for TradeFirst' do 
    let(:payment_method) { Payment::VALID_PAYMENT_METHODS.key('Trade First') }
    
    it 'has a field for trade partner name, company, and tradefirst card number' do
      expect(rendered).to have_selector('input#payment_t_name') 
      expect(rendered).to have_selector('input#payment_t_company_name') 
      expect(rendered).to have_selector('input#payment_tf_number') 
    end
  end
  
  context 'for Trade' do 
    let(:payment_method) { Payment::VALID_PAYMENT_METHODS.key('Trade') }
    
    it 'has a field for trade partner name, company, and trade description' do
      expect(rendered).to have_selector('input#payment_t_name') 
      expect(rendered).to have_selector('input#payment_t_company_name') 
      expect(rendered).to have_selector('textarea#payment_t_description') 
    end
  end
end
