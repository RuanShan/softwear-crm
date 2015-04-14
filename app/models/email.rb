class Email < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :emailable, polymorphic: true

  validates :body, :to, :from, :subject,  presence: true

end
