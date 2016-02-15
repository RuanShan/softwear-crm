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

    drop_table :users
  end

  def down
    drop_table :user_attributes
    # Pasted in from the create_users migration
    create_table(:users) do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at


      t.timestamps
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :unlock_token,         unique: true
  end
end
