class User
  include ActiveModel::Model
  include ActiveModel::Conversion

  ENDPOINT = 'localhost'

  attr_reader :id
  attr_reader :email
  attr_reader :first_name
  attr_reader :last_name
  attr_reader :persisted
  alias_method :persisted?, :persisted

  def self.primary_key
    :id
  end

  def self.base_class
    self
  end

  # Stupider version of has_many
  def self.has_many(assoc, options = {})
    assoc = assoc.to_s

    class_name  = options[:class_name]  || assoc.singularize.camelize
    foreign_key = options[:foreign_key] || 'user_id'

    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{assoc}
        #{class_name}.where(#{foreign_key}: id)
      end
    RUBY
  end

  # ------- These associations are crm-specific, of course --------
  has_many :orders,         foreign_key: 'salesperson_id'
  has_many :quote_requests, foreign_key: 'salesperson_id'
  has_many :search_queries, class_name: 'Search::Query'

  def pending_quote_requests
    quote_requests.where.not(status: 'quoted')
  end

  # ------- Now auth specific stuff again -------
  def self.arel_table
    Arel::Table.new('users', User)
  end

  def self.default_socket
    @default_socket ||= TCPSocket.open(ENDPOINT, 2900)
  end

  def self.query(message)
    begin
      default_socket.puts message
    rescue Errno::EPIPE => e
      @default_socket = TCPSocket.open(ENDPOINT, 2900)
      @default_socket.puts message
    end
    default_socket.gets.chomp
  end
  def query(*a)
    self.class.query(*a)
  end

  def self.validate_response(response_string)
    case response_string
    when 'denied'  then raise "Denied"
    when 'invalid' then raise "Invalid command"
    when 'sorry'   then raise "Authentication server encountered an error"
    else
      response_string
    end
  end
  def validate_response
    self.class.validate_response
  end

  def self.find(target_id)
    json = validate_response query "get #{target_id}"

    if json == 'nosuchuser'
      nil
    else
      object = new(JSON.parse(json))
      object.instance_variable_set(:@persisted, true)
      object
    end
  end

  def self.all
    json = validate_response query "all"

    objects = JSON.parse(json).map(&method(:new))
    objects.each { |u| u.instance_variable_set(:@persisted, true) }
    objects
  end

  def self.auth(token)
    response = validate_response query "auth #{Figaro.env.hub_app_name} #{token}"

    return false unless response =~ /^yes .+$/

    _yes, json = response.split(' ', 2)
    object = new(JSON.parse(json))
    object.instance_variable_set(:@persisted, true)
    object
  end

  def initialize(attributes={})
    update_attributes(attributes)
  end

  def update_attributes(attributes={})
    return if attributes.blank?
    attributes = attributes.with_indifferent_access

    @id         = attributes[:id]
    @email      = attributes[:email]
    @first_name = attributes[:first_name]
    @last_name  = attributes[:last_name]
  end

  def to_json
    {
      id:         @id,
      email:      @email,
      first_name: @first_name,
      last_name:  @last_name
    }
      .to_json
  end

  def reload
    json = validate_response query "get #{id}"

    update_attributes(JSON.parse(json))
    @persisted = true
    self
  end

  def full_name
    "#{@first_name} #{@last_name}"
  end

  # TODO ...
  def sales_manager?
    true
  end

  # -------------------- CRM Specific stuff -------------------

  def attributes
    return nil if id.nil?
    @attributes ||= UserAttributes.find_or_create_by(user_id: id)
  end

  def respond_to?(name, *a)
    super || attributes.respond_to?(name, *a)
  end

  def method_missing(name, *args, &block)
    if attributes.respond_to?(name)
      attributes.send(name, *args, &block)
    else
      raise NoMethodError.new("undefined method `#{name}' called on instance of User")
    end
  end
end
