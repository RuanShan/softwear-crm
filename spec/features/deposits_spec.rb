require 'spec_helper'
include ApplicationHelper

feature 'Payment Drops management', payment_drop_spec: true do
  given!(:valid_user) { create(:user) }
  given!(:store) { create(:valid_store) }
  given!(:payment_drop) {
    create(:payment_drop, payments: [ create(:valid_payment) ])
  }

  background(:each) { sign_in_as(valid_user) }

  context 'As a sales manager' do

    context 'with a deposit' do

    end

    context 'with an un-deposited payment drop' do
      background do
        allow_any_instance_of(Sunspot::Search::StandardSearch ).to receive(:results) { [payment_drop] }
      end

      scenario 'im presented with the undeposited dollar and check amount' do
        create(:payment_drop, cash_included: 3.0, payments: [create(:retail_payment, amount: 3.0)])
        visit deposits_path
        expect(page).to have_text 'Cash: $3.00'
      end

      context 'and valid data' do
        scenario 'I can create a deposit with it' do
          expect {
            visit deposits_path
            click_link 'New Deposit'
            fill_in 'Cash included', with: '0'
            fill_in 'Check included', with: '0'
            fill_in 'Deposit location', with: 'Bank at the corner'
            fill_in 'Deposit ID', with: 'ABC123'
            select valid_user.full_name, from: 'Deposited by'
            check "deposit_payment_drop_ids_#{payment_drop.id}"
            # icheck "deposit_payment_drop_ids_#{payment_drop.id}"
            click_button 'Create Deposit'
          }.to change{ Deposit.count }.from(0).to(1)

        end

        scenario 'I can create a deposit with it' do
          expect {
            visit deposits_path
            click_link 'New Deposit'
            fill_in 'Cash included', with: '10.0'
            fill_in 'Check included', with: '0'
            fill_in 'Difference reason', with: 'Because I am testing'
            fill_in 'Deposit location', with: 'Bank at the corner'
            fill_in 'Deposit ID', with: 'ABC123'
            select valid_user.full_name, from: 'Deposited by'
            # icheck "deposit_payment_drop_ids_#{payment_drop.id}"
            check "deposit_payment_drop_ids_#{payment_drop.id}"
            click_button 'Create Deposit'
          }.to change{ Deposit.count }.from(0).to(1)

        end
      end

      context 'and invalid data' do
        scenario 'I cannot create a deposit' do
          expect {
            visit deposits_path
            click_link 'New Deposit'
            fill_in 'Cash included', with: '10.01'
            fill_in 'Check included', with: '10.01'
            fill_in 'Deposit location', with: 'Bank at the corner'
            fill_in 'Deposit ID', with: 'ABC123'
            select valid_user.full_name, from: 'Deposited by'
            check "deposit_payment_drop_ids_#{payment_drop.id}"
            # icheck "deposit_payment_drop_ids_#{payment_drop.id}"
            click_button 'Create Deposit'
          }.to_not change{ Deposit.count }
        end
      end
    end


  end
end