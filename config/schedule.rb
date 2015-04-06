
set :output, {:error => '/home/ubuntu/RailsApps/crm.softwearcrm.com/shared/log/cron.error.log',
              :standard => '/home/ubuntu/RailsApps/crm.softwearcrm.com/shared/log/cron.log'}

every 30.minutes do
  rake "data:backup"
end

every 5.minutes do
  rake "quote_requests:import_from_wordpress"
end

every 60.minutes do
  rake "quote_requests:notify_sales_of_bad_quotes"
end
