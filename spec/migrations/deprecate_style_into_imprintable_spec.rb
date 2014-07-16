require 'spec_helper'
load 'db/migrate/20140716161035_deprecate_style_into_imprintable.rb'

describe DeprecateStyleIntoImprintable, slow: true do
  let!(:migration_version) { 20140716161035 }

  describe 'up' do

    before(:all) do
      @imprintable_without_style = Imprintable.new
      Imprintable.skip_callback(:create)
      @imprintable_without_style.save(:validate => false)
      Imprintable.set_callback(:create)

      # -----------------------
      # Before we rollback, imprintables exist with data, but styles don't exist at all
      # -----------------------
      ActiveRecord::Migrator.rollback(['db/migrate'])
      Imprintable.reset_column_information

      @style_values = {
          name: 'Crap',
          catalog_no: 'Crap 2',
          brand_id: 13,
          description: 'More Crap',
          sku: '12',
          retail: true
      }

      ActiveRecord::Base.connection.execute("INSERT INTO styles (name, catalog_no, brand_id, description, sku, retail)
            VALUES('#{@style_values[:name]}','#{@style_values[:catalog_no]}',
            '#{@style_values[:brand_id]}','#{@style_values[:description]}',
            '#{@style_values[:sku]}', #{@style_values[:retail]});
            ")

      res = ActiveRecord::Base.connection.execute("select id from styles where catalog_no = '#{@style_values[:catalog_no]}';")

      @imprintable_with_style = Imprintable.new(style_id: res[0]['id'])
      Imprintable.skip_callback(:create)
      @imprintable_without_style.save(:validate => false)
      Imprintable.set_callback(:create)


      ActiveRecord::Migrator.up(['db/migrate'])

    end

    it 'add columns style_name, style_catalog_no, style_description, style_sku, and retail to imprintables' do
      # reload functionality on instances not working
      # reload functionality for model schema not working
      # This bastardized way of reloading works
      imprintable = Imprintable.find(@imprintable_without_style.id)
      expect(imprintable).to respond_to(:style_name)
      expect(imprintable).to respond_to(:style_catalog_no)
      expect(imprintable).to respond_to(:style_description)
      expect(imprintable).to respond_to(:style_sku)
      expect(imprintable).to respond_to(:retail)
      expect(imprintable).to_not respond_to(:style_id)
    end

    it 'should assign values from style to imprintables', pending: true do

    end
    #
    #
    # it 'remove table styles'

  end

end