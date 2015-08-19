class ImprintMethodInkColor < ActiveRecord::Base
  belongs_to :imprint_method
  belongs_to :ink_color
end
