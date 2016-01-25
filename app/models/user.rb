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

  def validate_response(response_string)
    case response_string
    when 'denied'  raise "Denied"
    when 'invalid' raise "Invalid command"
    when 'sorry'   raise "Authentication server encountered an error"
    else
      response_string
    end
  end

  def self.find(target_id)
    default_socket.puts "get #{target_id}"
    json = validate_response default_socket.gets.chomp

    object = new(JSON.parse(json))
    object.instance_variable_set(:@persisted, true)
    object
  end

  def initialize(attributes={})
    update_attributes(attributes)
  end

  def update_attributes(attributes={})
    attributes = attributes.with_indifferent_access

    @id         = attributes[:id]
    @email      = attributes[:email]
    @first_name = attributes[:first_name]
    @last_name  = attributes[:last_name]
  end

  def update
    User.default_socket.puts "get #{target_id}"
    json = validate_response User.default_socket.gets.chomp
    update_attributes(JSON.parse(json))
    @persisted = true
  end
end
