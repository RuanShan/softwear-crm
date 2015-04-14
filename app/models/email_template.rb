class EmailTemplate < ActiveRecord::Base
  acts_as_paranoid

  TEMPLATE_TYPES = %w(Quote)

  belongs_to :quote

  validates :subject, :body, :name, :template_type, presence: true
  validates :from, :cc, :bcc, allow_blank: true, name_and_email: true

end
