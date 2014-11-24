

namespace :freshdesk do

  desc 'Pull contacts from freshdesk\'s api and store locally'
  task sync_contacts: :environment do
    page = 1
    response = FreshdeskModule.get_contacts(page)
    while response != []
      # save contacts
      response.each do |user_hash|
        contact = FreshdeskLocal::Contact.new(name: user_hash['user']['name'],
                                       email: user_hash['user']['email'],
                                       freshdesk_id: user_hash['user']['id'])
        if contact.save
          puts "Successfully added contact #{contact.name}"
        else
          puts "Unable to save contact #{contact.name}"
        end
      end

      page += 1
      response = FreshdeskModule.get_contacts(page)
    end
  end
end
