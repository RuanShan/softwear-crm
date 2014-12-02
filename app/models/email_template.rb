class EmailTemplate < ActiveRecord::Base
  acts_as_paranoid

  ### Validation
  validates :subject, presence: true
  validates :body, presence: true

  validates :from, allow_blank: true, email: true
  validates :cc, allow_blank: true, email: true
  validates :bcc, allow_blank: true, email: true


  #
  # Puts the parse error from Liquid on the error list if parsing failed
  #
  def after_validation
    errors.add :template, @syntax_error unless @syntax_error.nil?
  end

  ### Attributes

  #
  # body contains the raw template. When updating this attribute, the
  # email_template parses the template and stores the serialized object
  # for quicker rendering.
  #
  def body=(text)
    self[:body] = text

    begin
      @template = Liquid::Template.parse(text)
      self[:template] = Marshal.dump(@template)
    rescue Liquid::SyntaxError => error
      @syntax_error = error.message
    end
  end

  ### Methods

  #
  # Delivers the email
  #
  def deliver_to(address, options = {})
    options[:cc] ||= cc unless cc.blank?
    options[:bcc] ||= bcc unless bcc.blank?

    # Liquid doesn't like symbols as keys
    options.stringify_keys!
    TemplateMailer.deliver_email_template(address, self, options)
  end

  #
  # Renders body as Liquid Markup template
  #
  def render(options = {})
    template.render options
  end

  #
  # Usable string representation
  #
  def to_s
    "[EmailTemplate] From: #{from}, '#{subject}': #{body}"
  end

  private
  #
  # Returns a usable Liquid:Template instance
  #
  def template
    return @template unless @template.nil?

    if self[:template].blank?
      @template = Liquid::Template.parse body
      self[:template] = Marshal.dump @template
      save
    else
      @template = Marshal.load self[:template]
    end

    @template
  end
end
