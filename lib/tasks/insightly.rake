namespace :insightly do
  task custom_fields: :environment do
    include IntegratedCrms
    insightly.get_custom_fields
      .select { |f| f.custom_field_id =~ /OPPORTUNITY/ }
      .each { |f| puts "#{f.custom_field_id}: #{f.field_name} (#{f.field_type})" }
  end
end
