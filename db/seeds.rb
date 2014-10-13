def create_records(params_array, model)
  return if Rails.env.test?
  params_array.each do |params|
    after = params.delete :after
    record = model.new(params)
    if record.save
      after.call(record) if after
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

def create_imprintable_line_items(imprintable_maybe_id, color_maybe_id, options)
  imprintable = nil; color = nil
  if imprintable_maybe_id.respond_to? :id
    imprintable = imprintable_maybe_id
  else
    imprintable = Imprintable.find imprintable_maybe_id
  end
  if color_maybe_id.respond_to? :id
    color = color_maybe_id
  else
    color = Color.find color_maybe_id
  end

  variants = ImprintableVariant.where imprintable_id: imprintable.id, color_id: color.id
  records = variants.map do |v|
    options.merge imprintable_variant_id: v.id,
      unit_price: [5,10.55,12.99].sample,
      quantity: [0,0,1,2].sample
  end
  create_records(records, LineItem)
end

# Load seeds from a file in the ./seeds/ folder
# load_seeds_for User will load a file in ./seeds/users.rb
def load_seeds_for(seeds)
  filename = ''
  if seeds.respond_to? :name
    filename = seeds.name.underscore.pluralize
  else
    filename = seeds.to_s.underscore.pluralize
  end
  path = Rails.root.join('db', 'seeds', "#{filename}.rb").to_s
  puts "====From #{path}===="
  load path
  puts '===================='
end

# USER SEEDING
# ----------------

pw = 'pw4admin'
exists = !User.where(email: 'admin@softwearcrm.com').empty?
deleted_exists = !User.deleted.where(email: 'admin@softwearcrm.com').empty?
if !deleted_exists && !exists
	default_user = User.new(first_name: 'Admin', last_name: 'User',
													email: 'admin@softwearcrm.com',
													password: pw, password_confirmation: pw,
                          store_id: 1, freshdesk_email: 'devteam@annarbortees.com')
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
create_records([
  {
    first_name: 'Ricky',
    last_name: 'Winowiecki',
    email: 'something@somethingelse.com',
    password: 'something'
  },
  {
    first_name: 'Nigel',
    last_name: 'Baillie',
    email: 'somethingelse@something.com',
    password: 'something'
  },
  {
    first_name: 'Nicholas',
    last_name: 'Catoni',
    email: 'some@thing.com',
    password: 'something'
  },
  {
    first_name: 'David',
    last_name: 'Suckstorff',
    email: 'something@else.com',
    password: 'something'
  }
], User)


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
    {
      name: 'USPS First Class',
      tracking_url: 'https://tools.usps.com/go/TrackConfirmAction!input.action'
    },
    {
      name: 'UPS Ground',
      tracking_url: 'http://www.ups.com/tracking/tracking.html'
    }
], ShippingMethod)

# ImprintMethod SEEDING
# ----------------
ImprintMethod.create({name: 'Screen Printing'})

im = ImprintMethod.all.first
create_records([
  { name: 'Red', imprint_method_id: im.id },
  { name: 'Orange', imprint_method_id: im.id },
  { name: 'Yellow', imprint_method_id: im.id },
  { name: 'Green', imprint_method_id: im.id },
  { name: 'Blue', imprint_method_id: im.id },
  { name: 'Indigo', imprint_method_id: im.id },
  { name: 'Violet', imprint_method_id: im.id }
], InkColor)
ic_one = InkColor.all.first
ic_two = InkColor.all.second
ic_three = InkColor.all.third
create_records([
  {
    name: 'Chest',
    max_height: 5.5,
    max_width: 5.5,
    imprint_method_id: im.id
  },
  {
    name: 'Back',
    max_height: 5.5,
    max_width: 5.5,
    imprint_method_id: im.id
  }
], PrintLocation)
pl = PrintLocation.all.first

# Brand SEEDING
# ----------------
create_records([
  { name: 'American Apparel', sku: '01'},
  { name: 'Gildan', sku: '03'}
], Brand)

# Color SEEDING
# ----------------
create_records([
  { name: 'White', sku: '000'},
  { name: 'Black', sku: '001'},
  { name: 'Royal', sku: '002'},
  { name: 'Navy', sku: '003'},
  { name: 'Red', sku: '004'}
], Color)

# Imprintable SEEDING
# ---------------
create_records([
    { flashable: false, special_considerations: 'none', polyester: false, style_name: 'Unisex Fine Jersey Short Sleeve T-Shirt', style_catalog_no: '2001', style_description: 'The softest, smoothest, best-looking T-shirt available anywhere.', sku: '00', brand_id: Brand.find_by(name: 'American Apparel').id, sizing_category: 'Adult Unisex', material: '100% Cotton', proofing_template_name: 'Template_name_1', standard_offering: true, max_imprint_height: 10, max_imprint_width: 20, base_price: 10, xxl_price: 12, xxxl_price: 14, xxxxl_price: 15, xxxxxl_price: 16, xxxxxxl_price: 17 },
    { flashable: false, special_considerations: 'line dry', polyester: true, style_name: "Fine Jersey Short Sleeve Women's T-Shirt", style_catalog_no: '2102', style_description: 'This classic fitted t-shirt for women. Ultra soft and smooth 100% Fine Jersey Cotton', sku: '01', brand_id: Brand.find_by(name: 'American Apparel').id, sizing_category: 'Ladies', material: 'Polyester Blend', proofing_template_name: 'Template_name_2', standard_offering: false, max_imprint_height: 10, max_imprint_width: 20, base_price: 5, xxl_price: 6, xxxl_price: 7, xxxxl_price: 8, xxxxxl_price: 9, xxxxxxl_price: 10 },
    { flashable: true, special_considerations: 'do not print', polyester: false, style_name: 'Tank top', style_catalog_no: 'style_3', style_description: 'description', sku: '12', brand_id: 2, sizing_category: 'Toddler', material: 'Spandex', proofing_template_name: 'Template_name_3', standard_offering: true, max_imprint_height: 10, max_imprint_width: 20, base_price: 7, xxl_price: 10, xxxl_price: 13, xxxxl_price: 16, xxxxxl_price: 17 }
], Imprintable)

# Imprintable Variant SEEDING
# ---------------
variants = []
Imprintable.all.find_each do |imprintable|
  Size.all.find_each do |size|
    Color.all.find_each do |color|
      variants << {
        imprintable_id: imprintable.id,
        size_id: size.id,
        color_id: color.id
      }
    end
  end
end
create_records variants, ImprintableVariant

# Store SEEDING
# ---------------
create_records([
    { name: 'Ann Arbor Store' },
    { name: 'Ypsilanti Store' }
], Store)

# Order SEEDING
# --------------
create_records([
    {
      name: 'Test Order',
      firstname: 'Test',
      lastname: 'Tlast',
      email: 'test@test.com',
      twitter: '@test',
      in_hand_by: '1/2/2015 12:00 PM',
      terms: 'Half down on purchase',
      tax_exempt: false,
      delivery_method: 'Ship to one location',
      phone_number: '123-456-8456',
      store_id: 1,
      salesperson_id: 1
    }
  ], Order)
load_seeds_for Order

# Job SEEDING
# ---------------
load_seeds_for Job
j = Job.all.first

load_seeds_for LineItem

# Imprint SEEDING
# ---------------
create_records([
    job_id: j.id, print_location_id: pl.id
  ], Imprint)

# Artwork Request SEEDING
#------------------------
create_records([
    {
        description: 'No more thinking about bears.',
        artist_id: 1,
        imprint_method_id: im.id,
        print_location_id: pl.id,
        salesperson_id: 1,
        deadline: Time.now,
        artwork_status: 'Pending',
        priority: 1,
        ink_color_ids: [ic_one.id, ic_two.id, ic_three.id],
        job_ids: [j.id]
    },

    {
        description: 'Ill be taking these Huggies, and whatever cash ya got.',
        artist_id: 1,
        imprint_method_id: im.id,
        print_location_id: pl.id,
        salesperson_id: 1,
        deadline: Time.now + 1.day,
        artwork_status: 'Pending',
        priority: 5,
        ink_color_ids: [ic_one.id, ic_two.id, ic_three.id],
        job_ids: [j.id]
    }
               ], ArtworkRequest)

ar = ArtworkRequest.all.first

# Quote Request SEEDING
#----------------------
create_records([
   {
       name: 'QR without Salesperson',
       email: 'no_salesperson@emailworld.com',
       description: 'No Salesperson',
       approx_quantity: 55,
       date_needed: Time.now + 2.days,
       source: 'Source',
       salesperson_id: nil,
   },

   {
       name: 'QR with saleperson',
       email: 'salesperson@emailworld.com',
       description: 'Salesperson',
       approx_quantity: 55,
       date_needed: Time.now + 2.days,
       source: 'Source',
       salesperson_id: 1,
   }
              ], QuoteRequest)
