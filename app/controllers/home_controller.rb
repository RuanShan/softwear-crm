class HomeController < ApplicationController
  def index
    @order_warnings = Order.search do
      with(:warnings_count).greater_than 0
      with(:salesperson_full_name,  current_user.full_name)
    end.results

    @rejected_artwork_requests = ArtworkRequest.search do
      with(:state, :artwork_request_rejected)
      with(:salesperson_full_name,  current_user.full_name)
    end.results
  end

  def undock
    if (@qr_id = params[:quote_request_id]) && session[:docked].is_a?(Array)
      session[:docked].delete_if { |qr| qr[:id].to_i == @qr_id.to_i }
    else
      session[:docked] = []
    end
  end

  def not_allowed
  end

  def api_warnings
    @api_warnings = Warning.active.where("message like 'API%'").page(params[:page] || 1)

    generate_api_warnings if params[:generate_api_warnings]
  end

  private

  def format_dates
    @starting = format_time(params[:start_date])
    @ending = format_time(params[:end_date])
  end

  def generate_api_warnings
    format_dates
    orders_in_production = Order.where("production_state = ? and updated_at > ? and updated_at < ?", :in_production, @starting, @ending)
    puts "Processing #{orders_in_production.count} orders"
    orders_in_production.each do |o|

      begin
        o.prod_api_confirm_job_counts
        o.prod_api_confirm_shipment
        o.prod_api_confirm_artwork_preprod

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
#          j.prod_api_confirm_preproduction_trains
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
