ApplicationController.class_eval do
  cattr_accessor :max_file_upload_size
end

if Rails.env.production?
  begin
    IO.foreach("/etc/nginx/nginx.conf") do |line|
      if /client_max_body_size\s+(?<size>\d+)(?<unit>\w+)\s*;/ =~ line
        ApplicationController.max_file_upload_size = "#{size} #{unit}B"
        break
      end
    end
  rescue StandardError => e
    Rails.logger.error "Error fetching max file upload size from nginx config. "\
                       "#{e.class.name}: #{e.message}"
  end
end

if ApplicationController.max_file_upload_size.nil?
  ApplicationController.max_file_upload_size = "(unknown, probably 10mb)"
end
