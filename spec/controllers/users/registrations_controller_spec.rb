require 'spec_helper'

describe Users::RegistrationsController, user_spec: true do
	let!(:valid_user) { create :alternate_user }
	before :each do
	  setup_controller_for_warden
		request.env['devise.mapping'] = Devise.mappings[:user]
		controller.stub(:current_user).and_return valid_user
	end

	context 'logged in as a valid user' do

		context 'with valid parameters' do
			let!(:args) { [:create, user: attributes_for(:user)] }

			it 'redirects to users/index and displays message' do
				post *args
				expect(response).to redirect_to '/users'
				expect(flash[:notice]).to_not be_nil
				expect(flash[:notice]).to include 'success'
			end

			it "sends an email to the user's email address" do
				expect{ post *args }.to change{ActionMailer::Base.deliveries.count}.by 1
			end
		end

	end
end