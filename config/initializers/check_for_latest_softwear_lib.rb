unless Rails.env.production?
  version_file = URI("https://raw.githubusercontent.com/AnnArborTees/softwear-lib/master/lib/softwear/lib/version.rb")
  latest_version = Net::HTTP.get_response(version_file)

  if latest_version.is_a? Net::HTTPSuccess
    /VERSION\s*=\s*"(?<version_number>[\w\.]+)"/m =~ latest_version.body
    unless version_number.nil?
      unless `gem list softwear-lib`.include?(version_number)
        raise "You do not have the latest version of softwear-lib! Run `gem install softwear-lib`"
      end
    end
  end
end
