class Cost < ActiveRecord::Base
  include Softwear::Auth::BelongsToUser

  belongs_to_user_called :owner
  belongs_to :costable, polymorphic: true
end
