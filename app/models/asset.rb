class Asset < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :attachable, polymorphic: true
  has_attached_file :file, styles: { medium: "300x300>", thumb: "100x100>" }

end