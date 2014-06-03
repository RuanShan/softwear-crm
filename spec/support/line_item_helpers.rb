module LineItemHelpers
  def make_variant(color, imprintable)
    let!("#{color}_#{imprintable}".to_sym) do
      create :valid_imprintable_variant, color: send(color), imprintable: send(imprintable)
    end
    let!("#{color}_#{imprintable}_item".to_sym) do
      create :imprintable_line_item, imprintable_variant: send("#{color}_#{imprintable}")
    end
    before(:each) do
      job.line_items << send("#{color}_#{imprintable}_item")
    end
  end
end