module QuoteHelper
  def add_lis_from_pricing_hash(f, association, field_hash, group_name = nil, user_fields = nil)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id

    new_object.unit_price  = field_hash[:prices][:base_price]
    new_object.name        = field_hash[:name]
    new_object.description = field_hash[:description]

    if user_fields
      new_object.unit_price  = user_fields['unit_price'] if user_fields['unit_price']
      new_object.name        = user_fields['name'] if user_fields['name']
      new_object.description = user_fields['description'] if user_fields['description']
      new_object.quantity    = user_fields['quantity'] if user_fields['quantity']
      new_object.taxable     = user_fields['taxable'] if user_fields['taxable']
      new_object.url         = user_fields['url'] if user_fields['url']
    end

    f.fields_for(association, new_object, child_index: id) do |builder|
      render(
        association.to_s.singularize + '_fields',
        f: builder,
        group_name: group_name
      )
    end
  end

  def add_line_items_from_params(f, association, params)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    new_object.name = params[:name]
    new_object.description = params[:description]
    new_object.taxable = params[:taxable]
    new_object.quantity = params[:quantity]
    new_object.unit_price = params[:unit_price]
    new_object.url = params[:url]
    f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder)
    end
  end

  def line_items_from_last_attempt
    return nil unless session[:last_quote_line_items].try(:values)
    session[:last_quote_line_items]
      .values
      .select { |li| !li['group_name'].nil? }
  end
end
