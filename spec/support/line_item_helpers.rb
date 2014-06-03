module LineItemHelpers
  def make_variants(color, imprintable, sizes=[])
    sizes << :M if sizes.count == 0
    sizes.each do |size|
      let!("size_#{size.to_s.downcase}".to_sym) { create(:valid_size, name: size) } if Size.where(name: size).count <= 0

      let!("#{color}_#{imprintable}_#{size.to_s.downcase}".to_sym) do
        create :valid_imprintable_variant, color: send(color), imprintable: send(imprintable), size: send("size_#{size.to_s.downcase}")
      end
      let!("#{color}_#{imprintable}_#{size.to_s.downcase}_item".to_sym) do
        create :imprintable_line_item, imprintable_variant: send("#{color}_#{imprintable}_#{size.to_s.downcase}")
      end
      before(:each) do
        job.line_items << send("#{color}_#{imprintable}_#{size.to_s.downcase}_item")
      end
    end
  end
end