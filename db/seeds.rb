# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if User.deleted.where(email: 'admin@softwearcrm.com').empty?
	pw = 'pw4admin'
	default_user = User.new(firstname: 'Admin', lastname: 'User', 
													email: 'admin@softwearcrm.com',
													password: pw, password_confirmation: pw)
	default_user.confirm!
	default_user.save
	puts "Created user #{default_user.full_name} (#{default_user.email})"
else
	default_user = User.deleted.where(email: 'admin@softwearcrm.com').first
	default_user.deleted_at = nil
	default_user.save
	puts "Revived user #{default_user.full_name} (#{default_user.email})"
end