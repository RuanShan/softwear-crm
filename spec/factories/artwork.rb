FactoryGirl.define do
  factory :blank_artwork, class: Artwork do

    factory :valid_artwork do
      name 'Artwork'
      description 'This is artwork'
      local_file_location "#{Rails.root}/spec/fixtures/images/test.psd"
      tag_list ["Test", "Test2", "Test3"]
      artist { |a| a.association(:user) }
        
      artwork do |a|
        begin
          a.association(
            :valid_asset,
            file: File.open("#{Rails.root}/spec/fixtures/images/test.psd"),
          )
        rescue
          a.association(
            :valid_asset,
            file: File.open("#{Rails.root}/spec/fixtures/images/macho.png"),
          )
        end
      end

      factory :doc_type_preview do
        preview do |p|
          p.association(:valid_asset,
                        file: File.open("#{Rails.root}/spec/fixtures/fba/PackingSlipBadSku.txt")
          )
        end  
      end

      preview do |p|
        p.association(
          :valid_asset,
          file: File.open("#{Rails.root}/spec/fixtures/images/macho.png"),
        )
      end
    end
  end
end
