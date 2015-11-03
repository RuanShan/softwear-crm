
set :output, {:error => '/home/ubuntu/RailsApps/crm.softwearcrm.com/shared/log/cron.error.log',
              :standard => '/home/ubuntu/RailsApps/crm.softwearcrm.com/shared/log/cron.log'}

every :hour, at: 0 do
  rake "data:backup"
end

every :day, at: '7:00am' do 
  rake "warnings:create_for_orders"
end
