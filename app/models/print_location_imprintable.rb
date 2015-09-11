class PrintLocationImprintable < ActiveRecord::Base
  belongs_to :print_location
  belongs_to :imprintable

  belongs_to :platen_hoop
end
