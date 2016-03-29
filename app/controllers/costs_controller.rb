class CostsController < InheritedResources::Base
  skip_before_filter :verify_authenticity_token

  def mass_new
    # NOTE the block gets called when there were more results than the given limit.
    @line_items_by_imprintable = LineItem.in_need_of_cost(200) { |lim| @at_limit = lim }
  end

  def mass_create
    count = 0

    params.each do |key, value|
      next unless /imprintable_variant_(?<variant_id>\d+)_cost/ =~ key.to_s
      next if value.try(:strip).blank?

      value.gsub!(/\.\.+/, '.')

      count += LineItem.where(
        imprintable_object_type: 'ImprintableVariant',
        imprintable_object_id:   variant_id
      )
        .update_all cost_amount: value.to_f

      ImprintableVariant.where(id: variant_id).update_all last_cost_amount: value
    end

    if count == 0
      flash.now[:error] = "No values specified"
      render 'mass_new'
      return
    end

    flash[:success] = "Successfully added #{count} costs!"
    redirect_to action: :mass_new
  end
end
