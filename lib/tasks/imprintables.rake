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
    [1, 21, 22, 23, 26, 29, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40].each do |col|
      tags << ws[row, col] unless ws[row, col].blank?
    end
    tags
  end


  desc 'Import Imprintable Data from Google Doc - AATC Catalog of Standard Garment Offerings'
  task import_from_google_doc: :environment do
    session = GoogleDrive.login(Figaro.env['google_drive_user_name'], Figaro.env['google_drive_password'])
    ws = session.spreadsheet_by_key("1Als7xIDrcCLUt7yTy8_2li9C6bLrSWMV0U9c-9NGuVQ").worksheets[0]

    # Dumps all cells.
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
        style.name = ws[row, 3]
        if !style.save
          style.errors.each do |e|
            puts e.inspect
          end
        end

        if !Imprintable.where(style_id: style.id).exists?
          puts "Creating Imprintable #{brand.name} #{style.name}"
        end

        imprintable = Imprintable.find_or_initialize_by(style_id: style.id)
        imprintable.sample_print_locations = [Store.find_by(name: 'Ann Arbor')] unless ws[row, 19] == 'n'


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

end
