# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

pw = 'pw4admin'
default_user = User.new(firstname: 'Admin', lastname: 'User', 
												email: 'admin@softwearcrm.com',
												password: pw, password_confirmation: pw)
default_user.confirm!
default_user.save
