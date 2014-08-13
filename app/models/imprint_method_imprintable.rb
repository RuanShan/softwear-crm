class ImprintMethodImprintable < ActiveRecord::Base
  belongs_to :imprint_method
  belongs_to :imprintable
end