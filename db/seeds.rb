def create_records(params_array, model)
  return if Rails.env.test?
  params_array.each do |params|
    record = model.new(params)
    if record.save
      puts "Created #{model} #{params[:name]}"
    else
      puts "[ERROR] Can't create #{model}"
      record.errors.full_messages.each do |e|
        puts "[ERROR] #{e}"
      end
      puts '[ERROR] -----------------------'
    end
  end
end

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
	puts "Created default user (email: #{default_user.email}, password: #{pw})"
elsif deleted_exists
	default_user = User.deleted.where(email: 'admin@softwearcrm.com').first
	default_user.deleted_at = nil
	default_user.password = pw
	default_user.password_confirmation = pw
	default_user.save
	puts "Revived user #{default_user.full_name} (#{default_user.email}, #{pw})"
else
	default_user = User.where(email: 'admin@softwearcrm.com').first
	default_user.password = pw
	default_user.password_confirmation = pw
	default_user.save
	puts "Default user already exists! Email is admin@softwearcrm.com and password is #{pw}"
end


# Size SEEDING
# ----------------
create_records([
                   { name: 'Small', display_value: 'S', sku: '02', sort_order: 1 },
                   { name: 'Medium', display_value: 'M', sku: '03', sort_order: 2 },
                   { name: 'Large', display_value: 'L', sku: '04', sort_order: 3 },
                   { name: 'Extra Large', display_value: 'XL', sku: '05', sort_order: 4 }
               ], Size)

# ShippingMethod SEEDING
# ----------------

create_records([
    { name: 'USPS First Class', tracking_url: 'https://tools.usps.com/go/TrackConfirmAction!input.action'},
    { name: 'UPS Ground', tracking_url: 'http://www.ups.com/tracking/tracking.html'}
], ShippingMethod)

# Brand SEEDING
# ----------------
create_records([
    { name: 'American Eagle', sku: '06'},
    { name: 'Gildan', sku: '07'}
], Brand)

# Color SEEDING
# ----------------
create_records([
    { name: 'Blue', sku: '08'},
    { name: 'Red', sku: '09'}
], Color)

# Style SEEDING
# ----------------
create_records([
    { name: 'Short sleeve', catalog_no: 'style_1', description: 'description', sku: '10', brand_id: 1},
    { name: 'Long sleeve', catalog_no: 'style_2', description: 'description', sku: '11', brand_id: 1},
    { name: 'Tank top', catalog_no: 'style_3', description: 'description', sku: '12', brand_id: 2}
], Style)

# Imprintable SEEDING
# ---------------
create_records([
    { flashable: false, special_considerations: 'none', polyester: false, style_id: 1},
    { flashable: false, special_considerations: 'line dry', polyester: true, style_id: 2},
    { flashable: true, special_considerations: 'do not print', polyester: false, style_id: 3}
], Imprintable)

create_records([
    {
      name: 'Test Order',
      firstname: 'Test',
      lastname: 'Tlast',
      email: 'test@test.com',
      twitter: '@test',
      in_hand_by: '1/2/1015',
      terms: 'Half down on purchase',
      tax_exempt: false,
      is_redo: false,
      sales_status: 'Pending',
      delivery_method: 'Ship to one location',
      phone_number: '123-456-8456'
    }
  ], Order)

create_records([
    name: 'Test Job', description: "I hope these fields can be edited one day", order_id: 1
  ], Job)
