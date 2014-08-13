module LineItemHelpers
  # Defines a bunch of stuff for you
  # Be aware: the color and imprintable must be already defined
  # 
  #  make_variants :blue, :shirt, [:M, :L]
  # Will define the following:
  #  size_m            : Size
  #  size_l            : Size
  #  blue_shirt_m      : ImprintableVariant
  #  blue_shirt_l      : ImprintableVariant
  #  blue_shirt_m_item : LineItem
  #  blue_shirt_l_item : LineItem
  # 
  # Options include:
  #   lazy: boolean     - if true, all 'let's will be lazy
  #   not: array/symbol - 'let's for these types will be
  #                       lazy loaded
  def make_variants(color, imprintable, sizes=[], options={})
    sizes << :M if sizes.empty?
    
    excluded = [options[:not]].flatten.compact
    letfunc = lambda do |category|
      if options[:lazy] ||
         excluded.include?(category) ||
         excluded.include?(category.to_s.pluralize.to_sym)
        method(:let)
      else
        method(:let!)
      end
    end

    sizes.each do |size|
      letfunc.(:size).("size_#{size.to_s.downcase}") do
        create(:valid_size, name: size)
      end

      letfunc.(:imprintable_variant)
             .("#{color}_#{imprintable}_#{size.to_s.downcase}") do
        create(
          :associated_imprintable_variant,
          color:       send(color),
          imprintable: send(imprintable),
          size:        send("size_#{size.to_s.downcase}")
        )
      end

      letfunc.(:line_item)
             .("#{color}_#{imprintable}_#{size.to_s.downcase}_item") do
        create(
          :imprintable_line_item,
          imprintable_variant: send(
            "#{color}_#{imprintable}_#{size.to_s.downcase}"
          )
        )
      end

      unless options[:lazy] || excluded.include?(:job)
        before(:each) do
          job.line_items <<
            send("#{color}_#{imprintable}_#{size.to_s.downcase}_item")
        end
      end
    end
  end

  def make_stubbed_variants(color, imprintable, sizes = [], options = {})
    sizes << :M if sizes.empty?

    line_items = []

    sizes.each do |size|
      let!("size_#{size.to_s.underscore}") do
        build_stubbed :valid_size, name: size
      end

      imprintable_variant = "#{color}_#{imprintable}_#{size.to_s.underscore}"
      let!(imprintable_variant) do
        build_stubbed(
          :associated_imprintable_variant,
          color:       send(color),
          imprintable: send(imprintable),
          size:        send("size_#{size.to_s.underscore}")
        )
      end

      line_item = "#{color}_#{imprintable}_#{size.to_s.downcase}_item"
      let!(line_item) do
        build_stubbed(
          :imprintable_line_item,
          imprintable_variant: send(imprintable_variant),
        )
      end

      line_items << line_item
    end

    let("#{color}_#{imprintable}_items") { line_items.map(&method(:send)) }
  end

  def stub_imprintable_line_items(options)
    allow(LineItem).to receive_message_chain(
      :includes, :where, :where, :not
    )
      .and_return options[:with]
  end
end