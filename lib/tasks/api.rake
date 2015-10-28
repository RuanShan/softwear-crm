namespace :api do
  
  task confirm_production_configuration: :environment do
    
    orders_in_production = Order.where("production_state = ? and updated_at > ?", :in_production, 3.business_days.ago)
    puts "Processing #{orders_in_production.count} orders"
    orders_in_production.each do |o|
    
      begin
        o.prod_api_confirm_job_counts
        o.prod_api_confirm_shipment
        o.prod_api_confirm_art_trains
      
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

      o.jobs.each do |j| 
        begin
          j.prod_api_confirm_preproduction_trains
          j.prod_api_confirm_imprintable_train
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
      end    
    end
  end

end
