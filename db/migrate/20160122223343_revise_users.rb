class ReviseUsers < ActiveRecord::Migration
  def up
    create_table :user_attributes do |t|
      t.integer :user_id, index: true, unique: true
      t.integer :store_id
      t.string :freshdesk_email
      t.string :freshdesk_password
      t.string :encrypted_freshdesk_password
      t.string :insightly_api_key
      t.integer :signature_id
    end

    # NOTE this does assume that softwear-hub will have users with the same IDs as were in CRM
    # (so hub's import script should be called before this migration is invoked)
    query = "SELECT * from users"
    result = ActiveRecord::Base.connection.execute(query)
    result.each(as: :hash) do |row|
      user_attrs = UserAttributes.create(
        user_id:                      row['id'],
        store_id:                     row['store_id'],
        freshdesk_email:              row['freshdesk_email'],
        insightly_api_key:            row['insightly_api_key'],
        signature_id:                 row['signature_id'],
        freshdesk_password:           row['freshdesk_password'],
        encrypted_freshdesk_password: row['encrypted_freshdesk_password']
      )
    end

    # NOTE this assumes that the customer user's id is 52.
    # 0 is the special ID of the customer user in the new system.
    Payment.unscoped.where(salesperson_id: 52).update_all salesperson_id: 0

    rename_table :users, :old_users
  end

  def down
    drop_table :user_attributes
    rename_table :old_users, :users
  end
end
