FactoryGirl.define do
  factory :blank_email_template, class: EmailTemplate do

    factory :valid_email_template do
      subject 'Test subject'
      body    'Liquid shite'
      from    'noreply@test.com'
      cc      'other_customer@hotmail.com'
      bcc     'devteam@annarbortees.com'
    end
  end
end
