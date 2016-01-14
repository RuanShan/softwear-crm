require 'spec_helper'
include ApplicationHelper

feature 'Payment Drops management', payment_drop_spec: true do
  given!(:valid_user) { create(:user) }
  given!(:store) { create(:valid_store) }
  given!(:payment_drop) {
    create(:payment_drop, payments: [ create(:valid_payment) ])
  }

  background(:each) { login_as(valid_user) }

  context 'As a sales manager' do
    scenario 'I can access list of payment drops' do
      visit root_path
      click_link "Administration"
      click_link "Payment Drops"
      expect(page).to have_css("table#payment_drops_list")
    end

    context 'with undropped payments', js: true, current: true do
      given!(:payment) { create(:valid_payment, store_id: store.id) }
      given!(:check_payment) { create(:check_payment, store_id: store.id, amount: 1.0,
                                      order: create(:order, taxable_total: 20.0))
                              }

      background do
        allow_any_instance_of(Sunspot::Search::StandardSearch ).to receive(:results) {Payment.undropped}
      end

      scenario 'I can create a payment drop' do
        expect{
          visit new_payment_drop_path
          select store.name, from: "Store"
          sleep 1.5
          within("#payment-drop-undropped-payments-list") do
            find("input[value='#{payment.id}']").click
          end
          click_button "Create Payment Drop"
          sleep 1.5
        }.to change{ PaymentDrop.count }.by(1)
      end
      
      scenario 'I can see an undropped retail payment', retail_payment: true do
        create(:retail_payment, retail_description: 'What is up my man')

        visit new_payment_drop_path
        select store.name, from: "Store"
        sleep 1.5
        within("#payment-drop-undropped-payments-list") do
          expect(page).to have_content 'Retail: What is up my man'
        end
      end

      scenario "I can enter a reason when cash or check doesn't match expected cash or check"  do
        expect{
          visit new_payment_drop_path
          select store.name, from: "Store"
          sleep 1.5
          within("#payment-drop-undropped-payments-list") do
            find("input[value='#{check_payment.id}']").click
          end
          fill_in "Difference reason", with: 'A likely excuse'
          click_button "Create Payment Drop"
          sleep 1.5
        }.to change{ PaymentDrop.count }.by(1)
      end

      scenario "I cannot create a payment drop without a reason if check and cash amounts don't match" do
        expect{
          visit new_payment_drop_path
          select store.name, from: "Store"
          sleep 1.5
          within("#payment-drop-undropped-payments-list") do
            find("input[value='#{check_payment.id}']").click
          end
          sleep 1.5
          click_button "Create Payment Drop"
        }.to_not change{ PaymentDrop.count }
      end
    end

    scenario 'I cannot create a drop without any payments' do
      expect{
        visit new_payment_drop_path
        select store.name, from: "Store"
        click_button "Create Payment Drop"
      }.to_not change{ PaymentDrop.count }
    end

  end

end
