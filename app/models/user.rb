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

    object = new(JSON.parse(json))
    object.instance_variable_set(:@persisted, true)
    object
  end

  def self.all
    json = validate_response query "all"

    objects = JSON.parse(json).map(&method(:new))
    objects.each { |u| u.instance_variable_set(:@persisted, true) }
    objects
  end

  def self.auth(token)
    response = validate_response query "auth #{token}"

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

  def reload
    json = validate_response query "get #{id}"

    update_attributes(JSON.parse(json))
    @persisted = true
    self
  end

  def respond_to?(name, *a)
    super || attributes.respond_to?(name, *a)
  end

  def method_missing(name, *args, &block)
    attributes.send(name, *args, &block)
  end

  def attributes
    return nil if id.nil?
    @attributes ||= UserAttributes.find_or_create_by(user_id: id)
  end

  def full_name
    "#{@first_name} #{@last_name}"
  end

  # TODO ...
  def sales_manager?
    true
  end
end
