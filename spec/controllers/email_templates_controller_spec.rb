require 'spec_helper'

describe EmailTemplatesController, email_template_spec: true, story_265: true do
  let!(:template) { create(:valid_email_template) }
  let!(:valid_user) { create(:alternate_user) }
  before(:each) { sign_in valid_user }

  describe 'POST create' do
    context 'when successful' do
      before(:each) { post :create, email_template: attributes_for(:valid_email_template) }

      it 'flashes a notice to the user' do
        expect(flash[:notice]).to eq('Your new email template was successfully created.')
      end

      it 'redirects to index' do
        expect(response).to redirect_to email_templates_path
      end
    end
    context 'on failure' do
      before(:each) { post :create, user: attributes_for(:blank_user) }

      it 'redirects to new' do
        expect(response).to render_template :new
      end
    end
  end

  describe 'PUT update' do
    context 'when successful' do
      before(:each) { put :update, id: template.id, email_template: attributes_for(:valid_email_template, subject: 'New subject') }
      it 'flashes a notice to the user' do
        expect(flash[:notice]).to eq('Email template was successfully updated.')
      end

      it 'redirects to index' do
        expect(response).to redirect_to email_templates_path
      end
    end

    context 'on failure' do
      before(:each) { put :update, id: template.id, email_template: attributes_for(:valid_email_template, subject: '') }
      it 'renders edit' do
        expect(response).to render_template :edit
      end
    end
  end

  describe 'GET fetch_table_attributes' do
    before(:each) { get :fetch_table_attributes, table_name: Quote, format: :js }
    it 'assigns column names to be the attributes of Quote' do
      expect(assigns(:column_names)).to eq(Quote.column_names)
    end
  end

  describe 'GET preview_body' do
    it 'calls parse, render and assigns body' do
      expect_any_instance_of(Liquid::Template).to receive(:parse).and_return(Liquid::Template.new)
      expect_any_instance_of(Liquid::Template).to receive(:render).and_return('Rendered String')
      get :preview_body, email_template_id: template.id, format: :js
      expect(assigns(:body)).to eq('Rendered String')
    end
  end
end
