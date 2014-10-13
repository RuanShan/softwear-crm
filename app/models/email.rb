class Email < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :emailable, polymorphic: true

  validates :body, presence: true
  validates :sent_from, presence: true
  validates :sent_to, presence: true
  validates :subject, presence: true
end
