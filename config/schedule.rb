
set :output, {:error => '/home/ubuntu/RailsApps/crm.softwearcrm.com/shared/log/cron.error.log',
              :standard => '/home/ubuntu/RailsApps/crm.softwearcrm.com/shared/log/cron.log'}

every :hour, at: 0 do
  rake "data:backup"
end

every :hour, at: 30 do
  rake "quote_requests:notify_sales_of_bad_quotes"
end

every 5.minutes do
  rake "quote_requests:import_from_wordpress"
end
