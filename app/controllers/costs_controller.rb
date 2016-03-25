class CostsController < InheritedResources::Base
  skip_before_filter :verify_authenticity_token

  def mass_new
    # NOTE the block gets called when there were more results than the given limit.
    @line_items_by_imprintable = LineItem.in_need_of_cost(1000) { |lim| @at_limit = lim }
  end

  def mass_create
    now = %("#{Time.now.to_s(:db)}")

    count = 0

    params.each do |key, value|
      next unless /imprintable_variant_(?<variant_id>\d+)_cost/ =~ key.to_s
      next if value.try(:strip).blank?

      value.gsub!(/\.\.+/, '.')

      line_item_ids = LineItem.where(
        imprintable_object_type: 'ImprintableVariant',
        imprintable_object_id:   variant_id
      )
        .pluck(:id)

      values = line_item_ids.map do |line_item_id|
        %<("LineItem",#{line_item_id},#{value},"Imprintable","Cost of imprintables",#{current_user.id},#{now},#{now})>
      end
        .join(',')

      Cost.where(costable_type: 'LineItem', costable_id: line_item_ids).destroy_all
      Cost.connection.execute <<-SQL
        insert into costs
        (costable_type,costable_id,amount,type,description,owner_id,created_at,updated_at)
        values
        #{values}
      SQL

      ImprintableVariant.where(id: variant_id).update_all last_cost_amount: value

      count += line_item_ids.size
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
