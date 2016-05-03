require 'csv'
require 'google_drive'

namespace :imprintables do

  def brand_name(name)
    name = 'J America' unless name != 'J-America'
    name = 'Alternative' unless name != 'Alternative Apparel'
    name = 'Ultra Club' unless name != 'UltraClub'
    name = 'L.A.Tees' unless name != 'LAT'
    name = 'Port and Company' unless name != 'Port and Co.'
    name = 'Port and Company' unless name != 'Port and Co.'
    name = 'Nike' unless name != 'Nike Golf'
    name = 'Dry Duck' unless name != 'Dri-Duck'
    name = 'Sportek' unless name != 'Sport-Tek'
    name
  end

  def get_tags(ws, row)
    tags = []
    if ws[3, 12] == 'Main Supplier'
      # the google doc is contracted
      [1, 15, 16, 17, 20, 23, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34].each do |col|
        tags << ws[row, col] unless ws[row, col].blank?
      end
    else
      [1, 21, 22, 23, 26, 29, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40].each do |col|
        tags << ws[row, col] unless ws[row, col].blank?
      end
    end
    tags
  end

  def sizing_category(sizing_category)
    sizing_category = 'Youth Unisex' unless sizing_category != 'Youth'
    sizing_category
  end

  def get_coordinate_style_numbers(ws, row)
    style_numbers = ws[row, 28].split(',')
    style_numbers.map!{ |style_number| style_number.gsub(/\(.*\)/, "").squish }
  end


  desc 'Import Imprintable Data from Google Doc - AATC Catalog of Standard Garment Offerings'
  task import_from_google_doc: :environment do
    session = GoogleDrive.login(Figaro.env['google_drive_user_name'], Figaro.env['google_drive_password'])
    ws = session.spreadsheet_by_key("1Als7xIDrcCLUt7yTy8_2li9C6bLrSWMV0U9c-9NGuVQ").worksheets[0]

    # Create imprintables
    for row in 8..ws.num_rows
      if !ws[row,2].blank?
        if !Brand.where(name: brand_name(ws[row, 2])).exists?
          puts "Creating brand #{brand_name(ws[row, 2])}"
        end
        brand = Brand.find_or_create_by(name: brand_name(ws[row, 2]))

        if !Style.where(brand_id: brand.id, catalog_no: ws[row, 3]).exists?
          puts "Creating style #{brand.name} #{ws[row,3]}"
        end
        style = Style.find_or_initialize_by(brand_id: brand.id, catalog_no: ws[row, 3])
        style.name = ws[row, 4]
        if !style.save
          style.errors.full_messages.each do |e|
            puts e.inspect
          end
        end

        if !Imprintable.where(style_id: style.id).exists?
          puts "Creating Imprintable #{brand.name} #{style.name}"
        end
        imprintable = Imprintable.find_or_initialize_by(style_id: style.id)
        imprintable.sample_locations = [Store.find_by(name: 'Ann Arbor Store')] unless ws[row, 19] == 'n'
        imprintable.material = ws[row, 25]
        imprintable.standard_offering = true
        imprintable.sizing_category = sizing_category(ws[row,20])
        imprintable.proofing_template_name = ws[row,30]
        if !imprintable.save
          imprintable.errors.full_messages.each do |e|
            puts "Error saving #{style.catalog_no}"
            puts "Sizing Category Is #{sizing_category(ws[row,20])}"
          end
        end
        imprintable.weight = ws[row,24]
        imprintable.tag_list = get_tags(ws, row)
        imprintable.main_supplier = ws[row,18]
        imprintable.base_price = ws[row,6].gsub('$', '').to_f
        imprintable.xxl_price = ws[row,7].gsub('$', '').to_f
        imprintable.xxxl_price = ws[row,8].gsub('$', '').to_f
        imprintable.xxxxl_price = ws[row,9].gsub('$', '').to_f
        imprintable.xxxxxl_price = ws[row,10].gsub('$', '').to_f
        imprintable.xxxxxxl_price = ws[row,11].gsub('$', '').to_f
        imprintable.save
      end
    end

    # associate coordinates
    for row in 8..ws.num_rows
      if !ws[row,2].blank?
        begin
        brand = Brand.find_by(name: brand_name(ws[row, 2]))
        style = Style.find_by(brand_id: brand.id, catalog_no: ws[row, 3])
        imprintable = Imprintable.find_by(style_id: style.id)
        get_coordinate_style_numbers(ws, row).each do |catalog_no|
          coordinate_style = Style.find_by(brand_id: brand.id, catalog_no: catalog_no)
          coordinate = Imprintable.find_by(style_id: coordinate_style.id)
          if !imprintable.coordinates.include? coordinate
            imprintable.coordinates << coordinate
            puts "Adding #{coordinate.name} to #{imprintable.name}"
          end
        end
        rescue Exception => e
          puts e
        end
      end
    end

  end

  desc 'Import Imprintable Data from old Admin App using spreadsheets of database information'
  task import_from_csv: :environment do
    colors = {}
    sizes = {}
    brands = {}
    styles = {}


    CSV.foreach('tmp/colors.csv') do |row|
      color = Color.find_or_create_by(name: row[1])
      colors[row[0]] = color
    end

    CSV.foreach('tmp/brands.csv') do |row|
      brand = Brand.find_or_create_by(name: row[1], sku: row[2])
      brands[row[0]] = brand
    end

    CSV.foreach('tmp/inventory_sizes.csv') do |row|
      size = Size.find_or_create_by(name: row[1])
      sizes[row[0]] = size
    end

    CSV.foreach('tmp/inventory_lines.csv') do |row|
      style = Style.find_or_create_by({
                                          brand_id: brands[row[1]].id,
                                          catalog_no: row[2],
                                          name: row[3],
                                          description: row[4]
                                      })

      imprintable = Imprintable.find_or_create_by({
        style_id: style.id
      })

      styles[row[0]] = imprintable
    end

    begin
      CSV.foreach('tmp/inventories.csv') do |row|
        @row = row
        ImprintableVariant.find_or_create_by(
          imprintable_id: styles[@row[13]].id,
          size_id: sizes[@row[11]].id,
          color_id: colors[@row[12]].id
        )
      end
    rescue Exception => e
      puts "[ERROR] Exception #{e}"
    end

  end

  desc 'Initialize Size Display Values with Size Name'
  task initialize_size_display_values: :environment do
    Size.all.find_each do |size|
      if size.display_value.blank?
        size.display_value = size.name
        size.save
      end
    end
  end

  desc 'Import Imprintable Categories from the google Doc'
  task import_imprintable_categories: :environment do
    session = GoogleDrive.login(Figaro.env['google_drive_user_name'], Figaro.env['google_drive_password'])
    ss = session.spreadsheet_by_key("1Als7xIDrcCLUt7yTy8_2li9C6bLrSWMV0U9c-9NGuVQ")
    #ss.worksheets.each{|x| puts x.title}

    sheets_category = {
        3 => 'Tees & Tanks',
        4 => 'Sweatshirts & Fleece',
        5 => 'Pants & Shorts',
        6 => 'Business & Industrial Wear',
        7 => 'Jackets',
        8 => 'Headwear & Bags',
        9 => 'Athletics',
        10 => 'Fashionable',
        11 => 'Youth',
        12 => 'Something Different',
        13 => "What's Least Expensive"
    }

    sheets_category.each do |key, val|
      puts "Key is #{key}"
      ws = ss.worksheets[key]
      puts ws[1,1]
      for row in 7..ws.num_rows
        if !ws[row,2].blank?
          begin
            brand = Brand.find_by(name: brand_name(ws[row, 2]))
            style = Style.find_by(brand_id: brand.id, catalog_no: ws[row, 3])
            imprintable = Imprintable.find_by(style_id: style.id)

            if ws[row,3].include?('5000')
              puts "[#{ws[row,3]}] #{val}"
            end

            if !imprintable.imprintable_categories.exists?(name: val)
              ImprintableCategory.create(name: val, imprintable_id: imprintable.id)
            end
          rescue
            puts "Errors finding #{ws[row,2]} #{ws[row, 3]}"
          end

        end
      end
    end

  end

  desc "Parse costs for imprintable line items"
  task line_item_costs: :environment do
    count = 0
    current_variant_id = -1

    CSV.foreach(ENV['FILE'] || 'imprintable-line-items-without-costs.csv', headers: true) do |row|
      begin
        value = row['cost_amount']
        variant_id = row['imprintable_object_id']
        next if value.try(:strip).blank? || variant_id.blank?

        variant_id = variant_id.to_i
        value.gsub!(/\.\.+/, '.')
        value.gsub!(/$/, '')

        if variant_id != current_variant_id
          puts "Loading costs for #{ImprintableVariant.find(variant_id).full_name}..."
          current_variant_id = variant_id
        end

        count += LineItem.where(
          imprintable_object_type: 'ImprintableVariant',
          imprintable_object_id:   variant_id
        )
          .update_all cost_amount: value.to_f

        ImprintableVariant.where(id: variant_id).update_all last_cost_amount: value

      rescue StandardError => e
        puts "====================== ERROR ============================="
        puts "#{e.class} #{e.message}"
        puts e.backtrace
        puts "==================== END ERROR ==========================="
      end
    end

    puts "Updated prices for #{count} line items."
  end

  desc 'Parse standard product set sizes and colors from spreadsheet data'
  task import_sizes_and_colors_from_spreadsheet: :environment do
    CSV.foreach('tmp/size-color-info.csv', headers: true) do |row|
      if Imprintable.exists?
        imprintable = Imprintable.find(row['id'])

        from_hash = {}
        from_hash[:colors] = []
        from_hash[:sizes] = []

        color_names = row['colors'].split('!')
        size_display_values = row['sizes'].split('!')

        size_display_values.each do |size_display_value|
          from_hash[:sizes] << Size.find_by(display_value: size_display_value)
        end

        color_names.each do |color_name|
          from_hash[:colors] << Color.find_or_create_by(name: color_name)
        end

        puts 'Cannot create variants' unless imprintable.create_imprintable_variants(from_hash)
      else
        puts "Cannot find imprintable #{row['id']} '#{row['style']}'"
      end
    end
  end

end
