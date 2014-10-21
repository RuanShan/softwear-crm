namespace :stage do

  desc 'Prepare API settings in staging environment'
  task setup_api: :environment do

    # create API user
    User.create(
        email: 'staging-api-user@softwearcrm.com',
        password: 'pw4staging-api-user',
        first_name: 'API',
        last_name: 'User',
        authentication_token: 'authentication-token'
    )

    # set production-crm user
    # NOT YET CREATED

  end

end
