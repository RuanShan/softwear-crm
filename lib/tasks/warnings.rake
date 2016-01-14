namespace :warnings do
  task create_for_orders: :environment do

    # Invoice approval warnings
    begin
      orders = Order.where("in_hand_by > ? and in_hand_by < ?", 7.business_days.ago.strftime("%Y-%m-%d"), 7.business_days.from_now.strftime("%Y-%m-%d"))
      orders.each do |o|
        if o.invoice_should_be_approved_by_now? && o.invoice_state != 'approved'
          puts "Issuing invoice warning for order #{o.id} #{o.name}"
          o.warnings << Warning.new(
            source: 'Daily Warning Report',
            message: "Invoice should be approved for order #{o.id}, #{o.name}"
          )
          Sunspot.index o
        end
      end
    rescue Exception => e
      puts "Exception caught"
      puts "#{e.message}"
      Warning.create(
        source: 'Daily Warning Report',
        message: 'Exception caught while issuing invoice approval warnings'
      )
    end

    # negative balance warning
    begin
      orders = Order.search do
        with(:balance, true)
      end.results

      orders.each do |o|
        if o.balance < 0
          puts "Issuing order negative balance warning for order #{o.id} #{o.name}"
          o.warnings << Warning.new(
              source: 'Daily Warning Report',
              message: "Invoice balance is negative for order '#{o.id} '#{o.name}'"
          )
          Sunspot.index o
        end
      end
    rescue Exception => e
      puts "Exception caught"
      puts "#{e.message}"
      Warning.create(
          source: 'Daily Warning Report',
          message: 'Exception caught while issuing negative balance warnings'
      )
    end


    # artwork_requests warning
    begin
      orders = Order.where("in_hand_by > ? and in_hand_by < ?", 7.business_days.ago.strftime("%Y-%m-%d"), 7.business_days.from_now.strftime("%Y-%m-%d"))
      orders.each do |o|
        if o.missing_artwork_requests?
          puts "Issuing invoice warning for order #{o.id} #{o.name}"
          o.warnings << Warning.new(
            source: 'Daily Warning Report',
            message: "Imprints are missing artwork requests for order '#{o.id} '#{o.name}'"
          )
          Sunspot.index o
        end
      end
    rescue Exception => e
      puts "Exception caught"
      puts "#{e.message}"
      Warning.create(
        source: 'Daily Warning Report',
        message: 'Exception caught while issuing artwork_request warnings'
      )
    end

    # shipments warning
    begin
      orders = Order.where("in_hand_by > ? and in_hand_by < ?", 7.business_days.ago.strftime("%Y-%m-%d"), 7.business_days.from_now.strftime("%Y-%m-%d"))
      orders.each do |o|
        if (o.delivery_method == 'Ship to one location' || o.delivery_method == 'Ship to multiple locations') &&
            o.shipments.empty?

          puts "Issuing shipment warning for order #{o.id} #{o.name}"
          o.warnings << Warning.new(
            source: 'Daily Warning Report',
            message: "Shipment(s) are missing for order '#{o.id} '#{o.name}'"
          )
          Sunspot.index o
        end
      end
    rescue Exception => e
      puts "Exception caught"
      puts "#{e.message}"
      Warning.create(
        source: 'Daily Warning Report',
        message: 'Exception caught while issuing artwork_request warnings'
      )
    end
  end
end
