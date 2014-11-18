module QuoteHelper
  def add_lis_from_pricing_hash(f, association, field_hash)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    new_object.unit_price = field_hash[:prices][:base_price]
    new_object.name = field_hash[:name]
    f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder)
    end
  end

  def add_line_items_from_params(f, association, params)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    new_object.name = params[:name]
    new_object.description = params[:description]
    new_object.taxable = params[:description]
    new_object.quantity = params[:quantity]
    new_object.unit_price = params[:unit_price]
    new_object.url = params[:url]
    f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder)
    end
  end
end
