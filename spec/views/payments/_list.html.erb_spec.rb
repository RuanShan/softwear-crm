require 'spec_helper'

describe "payments/_list", type: :view do
  
  before(:each) { render 'payments/list', payments: [payment] }

  context 'for every payment' do 
    let(:payment) { create(:valid_payment) }

    it 'renders the salesperson, the id, the date, the amount, and the'\
       ' store at which it was collected' do 
      expect(rendered).to have_selector("dd.salesperson", text: payment.salesperson.full_name)
      expect(rendered).to have_selector("dt", text: "Payment #{payment.id}")
      expect(rendered).to have_selector("dd.date", text: payment.created_at.strftime('%a, %b %d, %Y %I:%M%p')) 
      expect(rendered).to have_selector("dd.amount", text: number_to_currency(payment.amount))
    end
  end

  context 'there is a cash payment' do
    let(:payment){ create(:cash_payment) }   
    
    it 'renders nothing more, just that it was a cash payment' do       
      expect(rendered).to have_selector("dd.method", text: 'Cash')
    end 
  end

  context 'there is a credit card payment' do
    let(:payment){ create(:credit_card_payment) }   
    
    it 'renders nothing more, just that it was a credit card payment' do       
      expect(rendered).to have_selector("dd.method", text: 'Credit Card')
    end 
  end

  context 'there is a check payment' do
    let(:payment){ create(:check_payment) }   
    
    it 'renders the check-givers drivers license no. and phone number' do       
      expect(rendered).to have_selector("dd.method", text: 'Check')
      expect(rendered).to have_selector("dd.check-dl-no", text: payment.check_dl_no)
      expect(rendered).to have_selector("dd.check-phone-no", text: payment.check_phone_no)
    end 
  end
  
  context 'there is a PayPal payment' do
    let(:payment){ create(:paypal_payment) }   
    
    it 'renders the paypal transaction id' do       
      expect(rendered).to have_selector("dd.method", text: 'PayPal')
      expect(rendered).to have_selector("dd.pp-transaction-id", text: payment.pp_transaction_id)
    end 
  end

  context 'there is a Trade First' do
    let(:payment){ create(:trade_first_payment) }   
    
    it 'renders the traders name, their company, and tradefirst account number' do       
      expect(rendered).to have_selector("dd.method", text: 'Trade First')
      expect(rendered).to have_selector("dd.t-name", text: payment.t_name)
      expect(rendered).to have_selector("dd.tf-number", text: payment.tf_number)
      expect(rendered).to have_selector("dd.t-company-name", text: payment.t_company_name)
    end 
  end
  
  context 'there is a Trade Payment' do
    let(:payment){ create(:trade_payment) }   
    
    it 'renders the traders name, their company, and trade description' do       
      expect(rendered).to have_selector("dd.method", text: 'Trade')
      expect(rendered).to have_selector("dd.t-name", text: payment.t_name)
      expect(rendered).to have_selector("dd.t-description", text: payment.t_description)
      expect(rendered).to have_selector("dd.t-company-name", text: payment.t_company_name)
    end 
  end

  context 'there is a Wire Transfer payment' do
    let(:payment){ create(:wire_transfer_payment) }   
    
    it 'renders the transaction id' do       
      expect(rendered).to have_selector("dd.method", text: 'Wire Transfer')
      expect(rendered).to have_selector("dd.pp-transaction-id", text: payment.pp_transaction_id)
    end 
  end
end
