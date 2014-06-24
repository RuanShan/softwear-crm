require 'csv'

namespace :imprintables do

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
