class ImprintableStore < ActiveRecord::Base
  belongs_to :imprintable
  belongs_to :store
end