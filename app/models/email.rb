class Email < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :emailable, polymorphic: true

  validates :emailable,  presence: true
  validates :to, :from, name_and_email: true, presence: true, unless: :freshdesk?
  validates :cc, :bcc, allow_blank: true, name_and_email: true, presence: true, unless: :freshdesk?
  validates :plaintext_body, presence: true, unless: :body
  validates :body, presence: true, unless: :plaintext_body
  validates :subject, presence: true, unless: :freshdesk?

  def populate_fields_from_template(email_template, records = {})
    drops = {}

    records.each do |key, val|
      class_name = "Liquid::#{key.to_s.camelize}Drop"
      instance = class_name.constantize.new(val)
      drops[key.to_s] = instance
    end

    %w(to from subject cc bcc body plaintext_body).each do |attribute|
      self.send("#{attribute}=", Liquid::Template.parse(email_template.send(attribute)).render(drops))
    end
  end

end
