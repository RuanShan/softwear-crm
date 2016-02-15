class AuthModel
  include ActiveModel::Model
  include ActiveModel::Conversion

  class AccessDeniedError < StandardError
  end
  class InvalidCommandError < StandardError
  end
  class AuthServerError < StandardError
  end

  # ============================= CLASS METHODS ======================
  class << self
    attr_writer :query_cache
    attr_accessor :query_cache_expiry
    alias_method :expire_query_cache_every, :query_cache_expiry=

    # ====================
    # The query cache takes message keys (such as "get 12") with response values straight from
    # the server. So yes, this will cache error responses.
    # You can clear this with <User Class>.query_cache.clear or <User Class>.query_cache = nil
    # ====================
    def query_cache
      @query_cache ||= ThreadSafe::Cache.new
    end

    def primary_key
      :id
    end

    def base_class
      self
    end

    # ====================
    # Not a fully featured has_many - must specify foreign_key if the association doesn't match
    # the model name.
    # ====================
    def has_many(assoc, options = {})
      assoc = assoc.to_s

      class_name  = options[:class_name]  || assoc.singularize.camelize
      foreign_key = options[:foreign_key] || 'user_id'

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{assoc}
          #{class_name}.where(#{foreign_key}: id)
        end
      RUBY
    end

    def arel_table
      @arel_table ||= Arel::Table.new(model_name.plural, self)
    end

    # ====================
    # This is only used to record how long it takes to perform queries for development.
    # ====================
    def record(before, after, type, body)
      ms = (after - before) * 1000
      # The garbage in this string gives us the bold and color
      Rails.logger.info "  \033[1m\033[33m#{type} (#{'%.1f' % ms}ms)\033[0m #{body}"
    end

    # ====================
    # Host of the auth server, from 'auth_server_endpoint' env variable.
    # Defaults to localhost.
    # ====================
    def auth_server_host
      endpoint = Figaro.env.auth_server_endpoint
      if endpoint.blank?
        'localhost'
      elsif endpoint.include?(':')
        endpoint.split(':').first
      else
        endpoint
      end
    end

    # ====================
    # Port of the auth server, from 'auth_server_endpoint' env variable.
    # Defaults to 2900.
    # ====================
    def auth_server_port
      endpoint = Figaro.env.auth_server_endpoint
      if endpoint.try(:include?, ':')
        endpoint.split(':').last
      else
        2900
      end
    end

    def default_socket
      @default_socket ||= TCPSocket.open(auth_server_host, auth_server_port)
    end

    # ====================
    # Bare minimum query function - sends a message and returns the response, and
    # handles a broken socket.
    # ====================
    def raw_query(message)
      begin
        default_socket.puts message

      rescue Errno::EPIPE => e
        @default_socket = TCPSocket.open(auth_server_host, auth_server_port)
        @default_socket.puts message
      end

      default_socket.gets.chomp
    end

    # ====================
    # Queries the authentication server only if there isn't a cached response.
    # ====================
    def query(message)
      before = Time.now

      expire_at = query_cache['_expire_at']
      if expire_at.blank? || Time.now > expire_at
        query_cache.clear
        query_cache['_expire_at'] = (query_cache_expiry || 1.hour).from_now
      end

      if cached_response = query_cache[message]
        response = cached_response
        action = "Authentication Cache"
      else
        response = raw_query(message)
        action = "Authentication Query"

        if query_cache
          query_cache[message] = response
        end
      end
      after = Time.now

      record(before, after, action, message)
      response
    end

    # ====================
    # Runs a query through the server without checking the cache. Only difference
    # between this and raw_query is that this one benchmarks the query on the info
    # log level just like normal query.
    # ====================
    def force_query(message)
      before = Time.now
      response = raw_query(message)
      after = Time.now

      record(before, after, "Authentication Query (forced)", message)
      response
    end

    # ====================
    # Expects a response string returned from #query and raises an error for the
    # following cases:
    #
    # - Access denied                       (AccessDeniedError)
    # - Invalid command (bad query message) (InvalidCommandError)
    # - Error on auth server's side         (AuthServerError)
    # ====================
    def validate_response(response_string)
      case response_string
      when 'denied'  then raise AccessDeniedError,   "Denied"
      when 'invalid' then raise InvalidCommandError, "Invalid command"
      when 'sorry'   then raise AuthServerError,     "Authentication server encountered an error"
      else
        response_string
      end
    end

    # ====================
    # Finds a user with the given ID
    # ====================
    def find(target_id)
      json = validate_response query "get #{target_id}"

      if json == 'nosuchuser'
        nil
      else
        object = new(JSON.parse(json))
        object.instance_variable_set(:@persisted, true)
        object
      end
    end

    # ====================
    # Returns an array of all registered users
    # ====================
    def all
      json = validate_response query "all"

      objects = JSON.parse(json).map(&method(:new))
      objects.each { |u| u.instance_variable_set(:@persisted, true) }
      objects
    end

    # ====================
    # Given a valid signin token:
    #   Returns the authenticated user for the given token
    # Given an invalid signin token:
    #   Returns false
    # ====================
    def auth(token)
      response = validate_response query "auth #{Figaro.env.hub_app_name} #{token}"

      return false unless response =~ /^yes .+$/

      _yes, json = response.split(' ', 2)
      object = new(JSON.parse(json))
      object.instance_variable_set(:@persisted, true)
      object
    end

    # ====================
    # Overridable logger method used when recording query benchmarks
    # ====================
    def logger
      Rails.logger
    end
  end

  # ============================= INSTANCE METHODS ======================

  REMOTE_ATTRIBUTES = [
    :id, :email, :first_name, :last_name,
    :profile_picture_url
  ]
  REMOTE_ATTRIBUTES.each(&method(:attr_reader))

  attr_reader :persisted
  alias_method :persisted?, :persisted

  # ====================
  # Various class methods accessible on instances
  def query(*a)
    self.class.query(*a)
  end
  def raw_query(*a)
    self.class.raw_query(*a)
  end
  def force_query(*a)
    self.class.force_query(*a)
  end
  def logger
    self.class.logger
  end
  # ====================

  def initialize(attributes = {})
    update_attributes(attributes)
  end

  def update_attributes(attributes={})
    return if attributes.blank?
    attributes = attributes.with_indifferent_access

    REMOTE_ATTRIBUTES.each do |attr|
      instance_variable_set("@#{attr}", attributes[attr])
    end
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
end
