module Customer
  class BaseController < InheritedResources::Base

    skip_before_filter :authenticate_user!
    layout 'no_overlay'

  end
end
