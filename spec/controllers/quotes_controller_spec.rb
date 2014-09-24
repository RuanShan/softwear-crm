require 'spec_helper'
include ApplicationHelper

describe QuotesController, js: true, quote_spec: true do
  let!(:valid_user) { create :alternate_user }
  let!(:quote) { create :valid_quote }

  before(:each) { sign_in valid_user }

  describe 'GET new' do
    before(:each) { get :new }

    it 'assigns the current action' do
      expect(assigns(:current_action)).to eq('quotes#new')
    end
  end

  describe 'GET index' do
    before(:each) { get :index }

    it 'assigns the current action' do
      expect(assigns(:current_action)).to eq('quotes#index')
    end
  end

  describe 'GET edit' do
    before(:each) do
      allow_any_instance_of(Quote).to receive(:all_activities).and_return(true)
      get :edit, id: quote.id
    end

    it 'assigns the current user' do
      expect(assigns(:current_user)).to eq(valid_user)
    end

    it 'assigns activities' do
      expect(assigns(:activities)).to eq(true)
    end

    it 'assigns current_action' do
      expect(assigns(:current_action)).to eq('quotes#edit')
    end
  end

  describe 'GET show' do
    it 'responds to json' do
      get :show, id: quote.id, format: :json
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['result']).to eq('success')
    end

    it 'responds to html' do
      get :show, id: quote.id, format: :html
      expect(response).to render_template('show')
    end
  end

  describe 'POST create' do
    context 'current_user is admin' do
      it 'should not call create_freshdesk_ticket' do
        expect(quote).to_not receive(:create_freshdesk_ticket)
        post :create, quote: attributes_for(:valid_quote)
      end
    end

    context 'current_user is in production' do
      before(:each) do
        allow(Rails).to receive_message_chain(:env, :production?).and_return true
      end

      it 'should call create_freshdesk_ticket' do
        expect_any_instance_of(Quote).to receive(:create_freshdesk_ticket).once
        post :create, quote: attributes_for(:valid_quote)
      end
    end
  end

  describe 'GET quote_select' do
    let!(:quote) { build_stubbed(:valid_quote) }
    let!(:line_item) { build_stubbed(:non_imprintable_line_item) }

    before(:each) do
      allow(Quote).to receive(:all).and_return([quote])
      allow(controller).to receive_message_chain(:session, :[], :[], :[]).and_return({})
      allow(LineItem).to receive(:new).and_return(line_item)
      get :quote_select, format: :js, index: '3'
    end

    it 'assigns quote_select_hash' do
      hash = {
        quotes: [quote],
        index: 3,
        new_line_item: line_item
      }
      expect(assigns(:quote_select_hash)).to eq(hash)
    end
  end

  describe 'POST stage_quote' do
    before(:each) do
      expect(Quote).to receive(:find).with(an_instance_of(String)).once
                       .and_return(build_stubbed(:valid_quote))
    end

    context 'with valid input' do
      it 'creates a new line_item, fires activity, and redirects' do
        expect_any_instance_of(Quote).to receive_message_chain(:line_items, :new, :save)
                                         .and_return true
        expect(controller).to receive(:fire_activity).once
        get :stage_quote, quote_id: quote.to_param, name: 'name', total_price: 4
        expect(response.status).to eq(302)
      end
    end

    context 'with invalid input' do
      it 'flashes an error to the user and redirects' do
        expect_any_instance_of(Quote).to receive_message_chain(:line_items, :new, :save)
                                         .and_return(false)
        get :stage_quote, quote_id: quote.to_param, name: 'name', total_price: -50
        expect(flash[:error]).to eq 'The line item could not be added to the quote.'
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'POST email_customer' do
    it 'assigns the quote and sends the customer an email' do
      expect{ QuoteMailer.delay.email_customer(instance_of(Hash)) }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
      expect{ (post :email_customer, quote_id: quote.id) }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)

      post :email_customer, quote_id: quote.id
      expect(assigns(:quote)).to eq(quote)
    end
  end

  describe 'GET populate_email_modal' do
    let!(:quote) { build_stubbed(:valid_quote) }
    it 'assigns quote' do
      expect(Quote).to receive(:find).once.and_return(quote)
      get :populate_email_modal, quote_id: quote.to_param, format: :js
      expect(assigns(:quote)).to eq(quote)
    end
  end
end
