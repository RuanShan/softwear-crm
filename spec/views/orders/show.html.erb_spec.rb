require 'spec_helper'

describe "orders/show", type: :view do
  
  let(:order) { build_stubbed(:order) }
  let(:pickup_order) { build_stubbed(:order, delivery_method: "Pickup in Ann Arbor") }

  context "Given an order with a shipping delivery method" do
    
    before{
      assign(:order, order)
      render
    }

    it 'should display the disclaimer' do
      expect(rendered).to have_text "* Arrival date varies by carrier" 
    end
  end

  context 'Given an order with a pick up delivery method' do
    
    before{
      assign(:order, pickup_order)
      render
    }

    it 'should not display the disclaimer' do
      expect(rendered).to_not have_text "* Arrival date varies by carrier"
    end
  end

  context 'Given a header and a footer on an invoice' do
    
    before(:each) do 
      assign(:order, order)
      render
    end

    it "Displays the store's name at the head of the invoice" do 
      expect(rendered).to have_css :h1, text: "#{order.store.name}"  
    end

    it "Displays the store's address at the foot of the invoice" do  
      within("#invoice_footer") do 
        order.store.address_array.each do |addr_field|
          expect(rendered).to have_text addr_field
        end  
        expect(rendered).to have_text order.store.phone 
        expect(rendered).to have_text order.store.sales_email 
      end
    end

    context 'The store has a logo' do 
      it "Displays the store logo at the header of the invoice"
    end
  end
end
