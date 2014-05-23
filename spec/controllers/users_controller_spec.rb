require 'spec_helper'

describe UsersController, user_spec: true do
	let!(:valid_user) { create :alternate_user }
	
	context '#create' do
		let!(:args) { [:create, user: attributes_for(:user)] }

		context 'signed in with valid account' do
			before(:each) { sign_in valid_user }

			it 'redirects to users/index and displays success message in the flash' do
				post *args
				expect(response).to redirect_to '/users'
				expect(flash[:notice]).to_not be_nil
				expect(flash[:notice]).to include 'success'
			end

			it "sends an email to the user's email address" do
				expect{ post *args }.to change{ActionMailer::Base.deliveries.count}.by 1
			end

			it 'creates the new user' do
				post *args
				expect(User.where(firstname: 'Test')).to exist
			end
		end

		context 'not signed in' do
			it 'does not allow a new user to be created' do
				post *args
				expect(response).to redirect_to new_user_session_path
			end
		end
	end

	context '#update_password', wip: true do
		context 'signed in' do
			before(:each) { sign_in valid_user }

			it 'should update the password if confirmation matches and current password is correct' do
				put :update_password, { user:
					{password: 'new_pass0', password_confirmation: 'new_pass0',
										current_password: '1234567890'}
				}

				expect(flash[:alert]).to be_nil
				expect(flash[:notice]).to include 'success'
			end

			it 'should fail if password does not match confirmation' do
				put :update_password, { user:
					{password: 'newpass1', password_confirmation: 'newpss324',
										current_password: '1234567890'}
				}

				expect(flash[:notice]).to be_nil
				expect(flash[:alert]).to include 'Error'
			end

			it 'should fail if current password is wrong' do
				put :update_password, { user:
					{password: 'newpass1', password_confirmation: 'newpass1',
										current_password: 'wrong0000'}
				}

				expect(flash[:notice]).to be_nil
				expect(flash[:alert]).to include 'Error'
			end
		end
	end

	context '#lock' do
		before(:each) do
			sign_in valid_user
		end

		it 'redirects to the sign in page' do
			get :lock, location: orders_path
			expect(response).to redirect_to new_user_session_path
		end

		it 'reassigns session[:lock][:location] to root_path if set to /lock' do
			get :lock, location: lock_user_path
			expect(session[:lock][:location]).to eq root_path
		end
	end

	context '#show' do
		it 'redirects to #index' do
			sign_in valid_user
			get :show, id: valid_user.id
			expect(response).to redirect_to users_path
		end
	end
end