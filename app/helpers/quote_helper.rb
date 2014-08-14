module QuoteHelper
  def add_prepopulated_fields(f, association, field_hash)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields',
             f: builder,
             unit_price: field_hash[:prices][:base_price],
             name: field_hash[:name])
    end
  end
end
