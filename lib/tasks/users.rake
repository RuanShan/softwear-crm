namespace :users do
  task eliminate_evil: :environment do |t, args|
    user_id_fields = {
      "Artwork"        => ['artist_id'],
      'ArtworkRequest' => ['artist_id', 'salesperson_id', 'approved_by_id'],
      'Comment'        => ['user_id'],
      'Cost'           => ['owner_id'],
      'Discount'       => ['user_id'],
      'InStoreCredit'  => ['user_id'],
      'Order'          => ['salesperson_id'],
      'Payment'        => ['salesperson_id'],
      'PaymentDrop'    => ['salesperson_id'],
      'Quote'          => ['salesperson_id', 'insightly_whos_responsible_id'],
      'QuoteRequest'   => ['salesperson_id'],
      'Search::Query'  => ['user_id'],
      'Shipment'       => ['shipped_by_id']
    }

    id_mapping = {
      61 => 37,
      18 => 49,
      5  => 6,
      75 => 74,
      62 => 63,
      78 => 51,
      66 => 26,
      54 => 65,
      3  => 2
    }

    user_id_fields.each do |class_name, fields|
      model = class_name.constantize

      fields.each do |field|
        id_mapping.each do |from, to|
          model.where(field => from).update_all(field => to)
        end
      end
    end
  end
end
