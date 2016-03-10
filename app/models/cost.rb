class Cost < ActiveRecord::Base
  include Softwear::Auth::BelongsToUser

  self.inheritance_column = nil

  belongs_to_user_called :owner
  belongs_to :costable, polymorphic: true
end
