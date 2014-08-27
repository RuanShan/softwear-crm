module QuoteHelper
  def add_lis_from_pricing_hash(f, association, field_hash)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields',
             f: builder,
             unit_price: field_hash[:prices][:base_price],
             name: field_hash[:name])
    end
  end

  def add_line_items_from_params(f, association, params)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields',
             f: builder,
             name: params[:name],
             description: params[:description],
             taxable: params[:taxable],
             quantity: params[:quantity],
             unit_price: params[:unit_price])
    end
  end
end
