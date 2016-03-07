Softwear::Lib::ApiController.class_eval do
  token_authenticate User, headers: { authentication_token: 'Crm-User-Token', email: 'Crm-User-Email' }
end
