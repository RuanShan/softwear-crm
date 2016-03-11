class CostsController < InheritedResources::Base
  def mass_new
    @line_items_by_imprintable = LineItem.in_need_of_cost(1000)
  end

  def mass_create
    query = <<-SQL
      insert into costs
      (costable_type,costable_id,amount,type,description,owner_id,created_at,updated_at)

      values
    SQL
    line_item_ids = []
    now = Time.now.to_s(:db)
    params.each do |key, value|
      next unless /line_item_(?<line_item_id>\d+)_cost/ =~ key.to_s
      next if value.try(:strip).blank?

      query += '('
      query += [
        '"LineItem"', line_item_id, value, '"Imprintable"', '"Cost of imprintables"',
        current_user.id, %("#{now}"), %("#{now}")
      ].join(',')
      query += '),'

      line_item_ids << line_item_id.to_i
    end

    if line_item_ids.empty?
      flash.now[:error] = "No values specified"
      render 'mass_new'
      return
    end

    query[-1] = '' # Lob off trailing ','

    Cost.where(costable_type: 'LineItem', costable_id: line_item_ids).destroy_all
    Cost.connection.execute(query)
    ImprintableVariant.enqueue_update_last_costs(line_item_ids)

    flash[:success] = "Successfully added #{line_item_ids.size} costs!"
    redirect_to action: :mass_new
  end
end
