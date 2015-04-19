FactoryGirl.define do
  factory :blank_email_template, class: EmailTemplate do

    factory :valid_email_template do
      name 'Valid E-mail Template'
      subject 'Test subject'
      body    'Liquid Text Here {{quote.id}}'
      plaintext_body 'Liquid Text Here Plaintext {{quote.id}}'
      from    'No Reply <noreply@test.com>'
      cc      'Other Customer <other_customer@hotmail.com>'
      bcc     'Dev Team <devteam@annarbortees.com>'
      template_type 'Quote'
    end
  end
end
