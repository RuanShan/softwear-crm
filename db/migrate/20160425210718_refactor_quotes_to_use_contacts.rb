class RefactorQuotesToUseContacts < ActiveRecord::Migration
  def change
    # add_column :quotes, :contact_id, :integer, index: true

    Quote.all.each do |quote|
      if Crm::Email.exists?(address: quote[:email])
        email = Crm::Email.find_by(address: quote[:email])
        quote.update_attributes(contact_id: email.contact_id)
      else
        phone_number = quote.format_phone_for_contact
        phone_number = '000-000-0000' if phone_number == '--'

        contact = Crm::Contact.new(
          first_name: quote[:first_name],
          last_name: quote[:last_name],
          primary_phone_attributes: {
            number: phone_number
          },
          primary_email_attributes: {
            address: quote[:email]
          }
        )

        begin
          contact.save!
        rescue
          puts "Quote #{quote.id} #{quote.created_at}"
          byebug
        end

        quote.update_attributes(contact_id: contact.id)
      end
    end
    rename_column :quotes, :first_name, :deprecated_first_name
    rename_column :quotes, :last_name, :deprecated_last_name
    rename_column :quotes, :email, :deprecated_email
    rename_column :quotes, :phone_number, :deprecated_phone_number

    # add_column :orders, :contact_id, :integer, index: true
    # Order.where.not(terms: 'Fulfilled by Amazon').each do |order|
    #   if  Crm::Email.exists?(address: order.email)
    #     email = Crm::Email.find_by(address: order.email)
    #     order.update_attributes(contact_id: email.contact_id)
    #   else
    #     phone_number = order.format_phone_for_contact
    #
    #     contact = Crm::Contact.new(
    #       first_name: order.firstname,
    #       last_name: order.lastname,
    #       primary_phone_attributes: {
    #         number: phone_number,
    #         extension: order.phone_number_extension
    #       },
    #       primary_email_attributes: {
    #         address: order.email.gsub(" ", "")
    #       }
    #     )
    #     unless contact.valid?
    #       if contact.errors["primary_phone.number"]
    #         contact.primary_phone.number = '000-000-0000'
    #       end
    #     end
    #
    #     begin
    #       contact.save!
    #     rescue
    #       puts "Order #{order.id} #{order.created_at}"
    #       byebug
    #     end
    #     order.update_attributes(contact_id: contact.id)
    #   end
    # end
    #
    # rename_column :orders, :firstname, :deprecated_first_name
    # rename_column :orders, :lastname, :deprecated_last_name
    # rename_column :orders, :email, :deprecated_email
    # rename_column :orders, :phone_number, :deprecated_phone_number

  end
end
