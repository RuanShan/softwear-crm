namespace :api do
  
  task confirm_production_configuration: :environment do
    
    orders_in_production = Order.where("production_state = ? and updated_at > ?", :in_production, 3.business_days.ago)
    puts "Processing #{orders_in_production.count} orders"
    orders_in_production.each do |o|
    
      begin
        production_order = o.production
      rescue ActiveResource::ResourceNotFound => e
        message = "API Failed to find PRODUCTION(#{o.softwear_prod_id}) for CRM(#{o.id})" 
        puts message 

        o.warnings << Warning.new(
          source: 'API Production Configuration Report', 
          message: message
        )
        
        Sunspot.index(o)
        next
      end  

      # Confirm that the production order has as many jobs as the order
      if o.jobs.count != production_order.jobs.count
        message = "API Job counts don't match for CRM(#{o.id})=#{o.jobs.count} PRODUCTION(#{production_order.id})=#{production_order.jobs.count}" 
        puts message 
        
        o.warnings << Warning.new(
          source: 'API Production Configuration Report', 
           message: message
        )
        
        Sunspot.index(o)
      end

      # Confirm that every job has an imprintable train if it requires it
      o.jobs.each do |j|
        begin
          production_job = j.production
        rescue ActiveResource::ResourceNotFound => e
          message = "API Failed to find PRODUCTION_JOB(#{j.softwear_prod_id}) for CRM_ORDER(#{o.id}) CRM_JOB(#{j.id})" 
          puts message 

          o.warnings << Warning.new(
            source: 'API Production Configuration Report', 
            message: message
          )
          
          Sunspot.index(o)
          next
        end  
        
        unless !j.imprintables.empty? && production_job.pre_production_trains.map{|x| x.train_class }.include?("imprintable_train")
      
          message = "API Job missing imprintable train CRM_ORDER(#{o.id}) CRM_JOB(#{j.id}) PRODUCTION(#{production_order.id})=#{production_job.id}" 
          puts message 
        
          o.warnings << Warning.new(
            source: 'Production Configuration Report', 
            message: message
          )
        end
        
        Sunspot.index(o)
      end
    end
  end

end
