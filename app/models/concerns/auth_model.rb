class AuthModel
  include ActiveModel::Model
  include ActiveModel::Conversion

  class AccessDeniedError < StandardError
  end
  class InvalidCommandError < StandardError
  end
  class AuthServerError < StandardError
  end
  class AuthServerDown < StandardError
  end

  # ============================= CLASS METHODS ======================
  class << self
    attr_writer :query_cache
    attr_accessor :last_query_cache
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

    # ======================================
    def primary_key
      :id
    end

    def base_class
      self
    end

    def relation_delegate_class(*)
      self
    end

    def unscoped
      self
    end

    def new(*args)
      if args.size == 3
        assoc_class = args[2].owner.class.name
        assoc_name = args[2].reflection.name
        raise "Unsupported user association: #{assoc_class}##{assoc_name}. If this is a belongs_to "\
              "association, you may have #{assoc_class} include BelongsToUser and call "\
              "`belongs_to_user_called :#{assoc_name}' instead of the traditional rails method."
      else
        super
      end
    end
    # ======================================

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
    # Expires the query cache, setting a new expiration time as well as merging
    # with the previous query cache, in case of an auth server outage.
    # ====================
    def expire_query_cache
      before = Time.now
      if last_query_cache
        query_cache.each_pair do |key, value|
          last_query_cache[key] = value
        end
      else
        self.last_query_cache = query_cache.clone
      end

      query_cache.clear
      query_cache['_expire_at'] = (query_cache_expiry || 1.hour).from_now
      after = Time.now

      record(before, after, "Authentication Expire Cache", "")
    end

    # ====================
    # Queries the authentication server only if there isn't a cached response.
    # ====================
    def query(message)
      before = Time.now

      expire_at = query_cache['_expire_at']
      expire_query_cache if expire_at.blank? || Time.now > expire_at

      if cached_response = query_cache[message]
        response = cached_response
        action = "Authentication Cache"
      else
        begin
          response = raw_query(message)
          action = "Authentication Query"

        rescue AuthServerError => e
          raise unless last_query_cache

          old_response = last_query_cache[message]
          if old_response
            response = old_response
            action = "Authentication Cache (due to error)"
            Rails.logger.error "AUTHENTICATION: The authentication server encountered an error. "\
                               "You should probably check the auth server's logs. "\
                               "A cached response was used."
          else
            raise
          end
        end

        query_cache[message] = response
      end
      after = Time.now

      record(before, after, action, message)
      response
    end

    # ====================
    # Runs a query through the server without error or cache checking.
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
  REMOTE_ATTRIBUTES.each(&method(:attr_accessor))

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

  def merge!(*)
  end
end
