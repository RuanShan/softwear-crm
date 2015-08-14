Softwear::Lib::ApiController.class_eval do
  acts_as_token_authentication_handler_for User
end
