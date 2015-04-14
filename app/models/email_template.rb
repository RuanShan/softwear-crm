class EmailTemplate < ActiveRecord::Base
  acts_as_paranoid

  TEMPLATE_TYPES = %w(Quote)

  belongs_to :quote

  validates :subject, :body, :name, :template_type, :to, :plaintext_body, :from, presence: true

end
