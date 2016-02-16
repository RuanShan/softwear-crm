class UserAttributes < ActiveRecord::Base
  include BelongsToUser

  attr_encrypted :freshdesk_password, key: 'h4rdc0ded1337ness'

  belongs_to_user
  belongs_to :store
  belongs_to :signature, class_name: 'Asset'

  accepts_nested_attributes_for :signature

  validates :freshdesk_email, email: true, allow_blank: true
  
  after_save :assign_image_assetables

  def full_name
    "#{first_name} #{last_name}"
  end

  # Don't assign attachment attributes if no file is specified,
  # do assign description always.
  def signature_attributes=(attrs)
    attrs = attrs.with_indifferent_access
    attrs[:description] ||= "#{user.try(:full_name) || 'Unknown'}'s Signature"

    super(attrs) unless attrs[:file].blank?
  end

  private

  # We use belongs_to for the images, because you cannot have two has_ones of the
  # same type. Because of this, the assets don't get the assetable information they
  # need for paths. This is a quick fix for that.
  def assign_image_assetables
    return if signature.nil?
    signature.assetable = self
    signature.save(validate: false)
  end
end
