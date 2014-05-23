# USER SEEDING
# ----------------

pw = 'pw4admin'
exists = !User.where(email: 'admin@softwearcrm.com').empty?
deleted_exists = !User.deleted.where(email: 'admin@softwearcrm.com').empty?
if !deleted_exists && !exists
	default_user = User.new(firstname: 'Admin', lastname: 'User', 
													email: 'admin@softwearcrm.com',
													password: pw, password_confirmation: pw)
	default_user.confirm!
	default_user.save
	puts "Created user #{default_user.full_name} (#{default_user.email})"
elsif deleted_exists
	default_user = User.deleted.where(email: 'admin@softwearcrm.com').first
	default_user.deleted_at = nil
	default_user.password = pw
	default_user.password_confirmation = pw
	default_user.save
	puts "Revived user #{default_user.full_name} (#{default_user.email})"
else
	default_user = User.where(email: 'admin@softwearcrm.com').first
	default_user.password = pw
	default_user.password_confirmation = pw
	default_user.save
	puts "Default user already exists! Email is admin@softwearcrm.com and password is #{pw}"
end

# Size SEEDING
# ----------------
sizes = [
    { name: 'Small', display_value: 'S', sku: '02', sort_order: 1 },
    { name: 'Medium', display_value: 'M', sku: '03', sort_order: 2 },
    { name: 'Large', display_value: 'L', sku: '04', sort_order: 3 },
    { name: 'Extra Large', display_value: 'XL', sku: '05', sort_order: 4 }
]
sizes.each do |size|
  if Size.create(size)
    puts "Created size #{size[:name]}"
  else
    puts "[ERROR] Can't create size #{shipping_method[:name]}"
  end
end

# ShippingMethod SEEDING
# ----------------

shipping_methods = [
    { name: 'USPS First Class', tracking_url: 'https://tools.usps.com/go/TrackConfirmAction!input.action'},
    { name: 'UPS Ground', tracking_url: 'http://www.ups.com/tracking/tracking.html'}
]
shipping_methods.each do |shipping_method|
  if ShippingMethod.create(shipping_method)
    puts "Created shipping method #{shipping_method[:name]}"
  else
    puts "[ERROR] Can't create shipping method #{shipping_method[:name]}"
  end
end