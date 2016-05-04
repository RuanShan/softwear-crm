class AddDefaultPricingOptions < ActiveRecord::Migration
  def up
    load_options(
      /Screen Print|Transfer/,
      'Color Count' => (1..12).to_a
    )

    load_options(
      /Digital Print/,
      'Print Size' => ['Standard', 'Oversized']
    )

    load_options(
      /Embroidery/,
      'Stitch Count' => 'Unspecified'
    )

    load_options(
      /Transfer/,
      'Color Count' => 'N/A'
    )

    load_options(
      /Transfer Printing/,
      'Color Count' => 'CMYK'
    )

    load_options(
      /Button Making/,
      'Size' => '1.5" Round'
    )

    load_options(
      /In-House Applique EMB/,
      'Stitch Count' => 'Unspecified'
    )

    load_options(
      /Pad Print/,
      'Color Count' => '1'
    )
  end

  private

  def load_options(imprint_method_name, options)
    @all_imprint_methods ||= ImprintMethod.all

    puts "  Preloading options: #{imprint_method_name.inspect} ---> #{options.inspect}"

    @all_imprint_methods.each do |imprint_method|
      next unless imprint_method_name =~ imprint_method.name

      options.each do |name, values|
        opt_type = Pricing::OptionType.find_or_create_by!(name: name, imprint_method_id: imprint_method.id)

        Array(values).each do |value|
          Pricing::OptionValue.find_or_create_by!(value: value.to_s, option_type_id: opt_type.id)
        end
      end
    end
  end
end
