FactoryGirl.define do
  factory :blank_email, class: Email do

    factory :valid_email do
      subject 'Test subject'
      body    'Liquid Text Here {{quote.id}}'
      plaintext_body 'Liquid Text Here Plaintext {{quote.id}}'
      to      'Customer <customer@hotmail.com>'
      from    'No Reply <noreply@test.com>'
      cc      'Other Customer <other_customer@hotmail.com>'
      bcc     'Dev Team <devteam@annarbortees.com>'
    end
  end
end
