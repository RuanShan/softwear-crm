require 'aws-sdk'

namespace :data do

  desc 'Dump and obfuscate data'
  task export_and_obfuscate_data: :environment do

  end

  desc 'Dump database'
  task backup: :environment do
    config   = Rails.configuration.database_configuration
    host     = config[Rails.env]["host"]
    database = config[Rails.env]["database"]
    username = config[Rails.env]["username"]
    password = config[Rails.env]["password"]

    puts "rake_task[data:backup] dumping database #{database}"
    system "mysqldump --opt --host=#{host} --user=#{username} --password=#{password} #{database} > #{Rails.root}/tmp/database.sql"

    puts "rake_task[data:backup] gzipping database #{database}"
    system "gzip -f #{Rails.root}/tmp/database.sql"

    unless ENV['aws_secret_access_key'].nil? && ENV['aws_access_key_id'].nil?
      puts 'rake_task[data:backup] copying file to aws bucket dev.crm.softwearcrm.com'
      AWS.config(access_key_id: ENV['aws_access_key_id'], secret_access_key: ENV['aws_secret_access_key'])
      s3 = AWS::S3.new
      key = 'database.sql.gz'
      s3.buckets['dev.crm.softwearcrm.com'].objects[key].write(:file => "#{Rails.root}/tmp/database.sql.gz")
    end
  end

  desc 'restore database from file saved on s3'
  task restore_from_s3: :environment do
    if ENV['aws_secret_access_key'].nil? or ENV['aws_access_key_id'].nil?
      puts "rake_task[data:restore_from_s3] AWS Variables are nil, exiting"
      exit(1)
    end

    config   = Rails.configuration.database_configuration
    host     = config[Rails.env]["host"]
    database = config[Rails.env]["database"]
    username = config[Rails.env]["username"]
    password = config[Rails.env]["password"]
    puts 'rake_task[data:restore_from_s3] copying file from aws bucket locally'
    AWS.config(access_key_id: ENV['aws_access_key_id'], secret_access_key: ENV['aws_secret_access_key'])
    s3 = AWS::S3.new
    key = 'database.sql.gz'
    s3_file = s3.buckets['dev.crm.softwearcrm.com'].objects[key]

    puts "rake_task[data:restore_from_s3] file last edited #{s3_file.last_modified.strftime('%Y-%m-%d %H:%M:%S')}"

    File.open("#{Rails.root}/tmp/database.sql.gz", 'wb') do |file|
      s3_file.read do |chunk|
        file.write(chunk)
      end
    end

    puts "rake_task[data:restore_from_s3] unzipping database #{database}.gz"
    system "gzip -d -f #{Rails.root}/tmp/database.sql.gz"

    puts "rake_task[data:restore_from_s3] populating database #{database}"
    system "mysql --host=#{host} --user=#{username} --password=#{password} #{database} < #{Rails.root}/tmp/database.sql"


  end

end
