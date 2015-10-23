namespace :upload do
  desc 'Load compatible imprint methods for imprintables from a template spreadsheet and data spreadsheet.'
  task compatible_imprint_methods: :environment do
    template_filename = ENV['TEMPLATE'] || ENV['template']
    data_filename     = ENV['DATA'] || ENV['data']

    if template_filename.blank?
      puts "Please specify a template file with template=filename"
    end
    if data_filename.blank?
      puts "Please specify a data file with data=filename"
    end
    if template_filename.blank? || data_filename.blank?
      next
    end

    # ============================
    imprintables_for = {}
    # Format: { template_name => [imprintables] }
    # So, this is one-to-many.

    # ============= PARSE TEMPLATES ==============
    CSV.foreach(File.expand_path(template_filename), headers: :first_row) do |row|
      imprintable_name = row['Imprintable'].try(:strip)
      template         = row['TemplateName'].try(:strip)

      next if imprintable_name.blank? && template.blank?

      if imprintable_name.blank?
        puts "Tried to map #{template} to empty imprintable. Skipping."
        next
      end
      if template.blank?
        puts "Tried to map #{imprintable_name} to no template. Skipping."
        next
      end

      results = Imprintable.search { fulltext imprintable_name }.results
      if results.empty?
        puts "Couldn't find an imprintable matching '#{imprintable_name}'. Skipping."
        next
      end
      if results.size > 1
        puts "Found #{results.size} imprintables matching '#{imprintable_name}': "\
             "#{results.map(&:id)}. Using all of them."
      end

      imprintables_for[template] ||= []
      imprintables_for[template] += results
    end
    puts "============================ TEMPLATES: #{imprintables_for.keys.join(', ')} ============================"

    # ============================

    # ============= PARSE ACTUAL DATA ==============
    updated_imprintable_count = 0
    row_count = 1 # Start at one then increment, because of the header.
    CSV.foreach(File.expand_path(data_filename), headers: :first_row) do |row|
      row_count += 1

      template            = row['TemplateName'].try(:strip)
      imprint_method_name = row['ImprintMethod'].try(:strip)
      print_location_name = row['Location'].try(:strip)
      platen_hoop_name    = row['PlatenHoop'].try(:strip)
      max_width           = row['MaxWidth'].try(:strip)
      max_height          = row['MaxHeight'].try(:strip)
      ideal_width         = row['IdealWidth'].try(:strip)
      ideal_height        = row['IdealHeight'].try(:strip)

      if template.blank?
        if imprint_method_name.blank?
          puts "No template or imprint method specified on row #{row_count}."
        else
          puts "Specified imprint method #{imprint_method_name} but no template. Skipping row #{row_count}."
        end
        next
      end

      imprintables = imprintables_for[template]

      if imprintables.blank?
        puts "No template called '#{template}' was defined. Skipping row #{row_count}."
        next
      end

      # == Fetch imprintmethods/printlocations ==
      if imprint_method_name.blank? || print_location_name.blank?
        puts "Insufficient print location info on data row #{row_count}."
      else
        imprint_method = ImprintMethod.find_by(name: imprint_method_name)

        if imprint_method.nil?
          puts "Couldn't find imprint method with name '#{imprint_method_name}' (row #{row_count})."
        else
          print_location = imprint_method.print_locations.where(name: print_location_name).first

          if print_location.nil?
            puts "Couldn't find print location #{imprint_method_name}: #{print_location_name} "\
                 "(row #{row_count})."
          end
        end
      end

      # == Fetch platen/hoop information if applicable ==
      if platen_hoop_name.blank?
        puts "No platen/hoop provided on row #{row_count}."
      else
        platen_hoop = PlatenHoop.find_by(name: platen_hoop_name)

        if platen_hoop.nil?
          puts "Couldn't find platen_hoop with name '#{platen_hoop_name}' (row #{row_count})."
        end
      end

      # == Validate width/heights ===
      if print_location
        puts "No max width on row #{row_count}. (Ignore if not a problem)"    if max_width.blank?
        puts "No max height on row #{row_count}. (Ignore if not a problem)"   if max_height.blank?
        puts "No ideal width on row #{row_count}. (Ignore if not a problem)"  if ideal_width.blank?
        puts "No ideal height on row #{row_count}. (Ignore if not a problem)" if ideal_height.blank?
      end

      # === Apply changes!!! ===
      if print_location
        imprintables.each do |imprintable|
          join = PrintLocationImprintable.find_or_create_by(
            print_location_id: print_location.id,
            imprintable_id:    imprintable.id
          )
          set = ->(field, local) { join.send(field, local) unless local.blank? }

          set[:max_imprint_width=,    max_width]
          set[:max_imprint_height=,   max_height]
          set[:ideal_imprint_width=,  ideal_width]
          set[:ideal_imprint_height=, ideal_height]
          set[:platen_hoop_id=, platen_hoop.try(:id)]

          if join.save
            updated_imprintable_count += 1
          else
            puts "Failed to save join table for row #{row_count}: #{join.errors.full_messages.join(', ')}"
          end
        end
      end
    end # CSV.foreach

    puts "====================== DONE ====================="
    puts "Successfully updated #{updated_imprintable_count} imprintables."
  end
end
