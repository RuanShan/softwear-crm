class CreateSettings < ActiveRecord::Migration
  def up
    create_table :settings do |t|
      t.string :name
      t.string :val
      t.boolean :encrypted

      t.datetime :deleted_at
      t.timestamps
    end

    url = Setting.new(name: 'freshdesk_url',
                      val: 'http://annarbortees.freshdesk.com',
                      encrypted: false)

    email = Setting.new(name: 'freshdesk_email',
                        val: 'david.s@annarbortees.com',
                        encrypted: true)

    password = Setting.new(name: 'freshdesk_password',
                           val: '',
                           encrypted: true)
    Setting.transaction do
      puts "was unable to save #{url.name}" unless url.save
      puts "was unable to save #{email.name}" unless email.save
      puts "was unable to save #{password.name}" unless password.save(validate: false)
    end


  end

  def down
    %w(freshdesk_url freshdesk_name freshdesk_password).each do |w|
      to_delete = Setting.find_by name: w
      to_delete.destroy if to_delete
    end

    drop_table :settings
  end

end
