every 30.minutes do
  rake "data:backup"
end

every 5.minutes do
  rake "quote_requests:import_from_wordpress"
end

every 60.minutes do
  rake "quote_requests:notify_sales_of_bad_quotes"
end

every :day, :at => '2:00 am' do
  rake "tmp:sessions:clear"
end
