module PublicActivityExtension
  def owner
    if owner_type == 'User'
      @owner ||= User.find(owner_id)
    else
      super
    end
  end

  def recipient
    if recipient_type == 'User'
      @recipient ||= User.find(recipient_id)
    else
      super
    end
  end
end

PublicActivity::Activity.class_eval do
  include PublicActivityExtension
end
