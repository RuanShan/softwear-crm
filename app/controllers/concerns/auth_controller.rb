class AuthController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:set_session_token, :clear_query_cache]

  # ====================
  # Comes from an img tag on softwear-hub to let an authorized app know that
  # a user has signed in.
  # ====================
  def set_session_token
    encrypted_token = params[:token]
    redirect_to Figaro.env.softwear_hub_url and return if encrypted_token.blank?

    Rails.logger.info "RECEIVED ENCRYPTED TOKEN: #{encrypted_token}"

    decipher = OpenSSL::Cipher::AES.new(256, :CBC)
    decipher.decrypt
    decipher.key = Figaro.env.token_cipher_key
    decipher.iv  = Figaro.env.token_cipher_iv

    session[:user_token] = decipher.update(Base64.urlsafe_decode64(encrypted_token)) + decipher.final

    render inline: 'Done'
  end

  # ====================
  # Comes from an img tag on softwear-hub when there has been a change to user
  # attributes or roles and the cache should be cleared.
  # ====================
  def clear_query_cache
    AuthModel.descendants.each do |user|
      user.query_cache.clear
    end

    render inline: 'Done'
  end
end
