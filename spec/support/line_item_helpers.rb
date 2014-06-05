module LineItemHelpers
  # Options include:
  #   lazy: boolean     - if true, all 'let's will be lazy
  #   not: array/symbol - 'let's for these types will be
  #                       lazy loaded
  def make_variants(color, imprintable, sizes=[], options={})
    sizes << :M if sizes.count == 0
    
    excluded = [options[:not]].flatten.compact
    letfunc = -> (category) { 
      if options[:lazy] || excluded.include?(category)
        method(:let)
      else
        method(:let!)
    }

    sizes.each do |size|
      letfunc.call(:size).call("size_#{size.to_s.downcase}".to_sym) { create(:valid_size, name: size) } if Size.where(name: size).count <= 0

      letfunc.call(:imprintable_variant).call("#{color}_#{imprintable}_#{size.to_s.downcase}".to_sym) do
        create :valid_imprintable_variant, color: send(color), imprintable: send(imprintable), size: send("size_#{size.to_s.downcase}")
      end
      letfunc.call(:line_item).call("#{color}_#{imprintable}_#{size.to_s.downcase}_item".to_sym) do
        create :imprintable_line_item, imprintable_variant: send("#{color}_#{imprintable}_#{size.to_s.downcase}")
      end
      before(:each) do
        job.line_items << send("#{color}_#{imprintable}_#{size.to_s.downcase}_item")
      end unless options[:lazy] || excluded.include?(:job)
    end
  end

  # Same as tossing lazy: true onto a standard make_variants call
  def make_variants!(color, imprintable, sizes=[], options={})
    make_variants color, imprintable, sizes, options.merge {lazy: true}
  end
end