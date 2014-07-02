class SampleLocation < ActiveRecord::Base
  belongs_to :imprintable
  belongs_to :store
end
