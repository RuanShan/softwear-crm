class CustomerUpload < ActiveRecord::Base
  belongs_to :quote_request
end
