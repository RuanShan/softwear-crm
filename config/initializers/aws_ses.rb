if Rails.env.production?
  ActionMailer::Base.add_delivery_method(
    :ses, AWS::SES::Base,
    access_key_id: Figaro.env.aws_access_key_id,
    secret_access_key: Figaro.env.aws_secret_access_key
  )
end
