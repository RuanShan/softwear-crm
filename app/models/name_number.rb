class NameNumber < ActiveRecord::Base
  belongs_to :imprint
  belongs_to :imprintable_variant
end
