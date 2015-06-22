
set :output, {:error => '/home/ubuntu/RailsApps/crm.softwearcrm.com/shared/log/cron.error.log',
              :standard => '/home/ubuntu/RailsApps/crm.softwearcrm.com/shared/log/cron.log'}

every :hour, at: 0 do
  rake "data:backup"
end