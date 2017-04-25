require 'active_support/core_ext/hash/indifferent_access'

module Maxwell
  class Client
    class << self
      attr_accessor :base_url,
                    :token
    end

    def initialize(opts = {})
      @base_url       = Maxwell::Client.base_url || opts.fetch(:base_url) { missing_argument(:base_url) }
      @token          = Maxwell::Client.token || opts.fetch(:token) { nil }
      @jwt            = opts.fetch(:jwt, nil)
      @body           = opts.fetch(:body, "")
      @request_method = opts.fetch(:request_method) { :get }
      @endpoint       = opts.fetch(:endpoint) { missing_argument(:endpoint) }
    end

    def self.authenticate(opts = {})
      if opts[:email] && opts[:password]
        auth_opts = {
          email: opts.fetch(:email, ''),
          password: opts.fetch(:password, ''),
        }

        self.post('/auth', { body: auth_opts })
      end
    end

    def self.get(path, opts = {})
      perform(path, :get, opts)
    end

    def self.post(path, opts = {})
      perform(path, :post, opts)
    end

    def self.put(path, opts = {})
      perform(path, :put, opts)
    end

    def self.delete(path, opts = {})
      perform(path, :delete, opts)
    end

    def perform
      http = Net::HTTP.new(uri.host, uri.port)
      klass = "Net::HTTP::#{request_method.to_s.capitalize}"

      request = Object.const_get(klass).new(uri.request_uri)

      case request_method
      when :post, :put, :patch, :delete
        request.body = body
      end

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # Missing auth and attempting to make a request
      if token.nil? && jwt.nil? && !auth_uri?
        raise Maxwell::UnauthorizedRequest, 'Please supply an API key in an initializer or Token with your request'
      end

      # Set authorization header unless auth request
      unless auth_uri?
        request['Authorization'] = token.nil? ? "Bearer #{jwt}" : "Token #{token}"
      end

      request['Content-Type'] = 'application/json'
      request['Accept'] = 'application/vnd.himaxwell.com; version=1,application/json'

      http.request(request)
    end

    private

    attr_reader :base_url,
                :token,
                :jwt,
                :body,
                :request_method,
                :endpoint

    def self.perform(path, request_method, opts = {})
      opts = HashWithIndifferentAccess.new(opts)

      client = ::Maxwell::Client.new(
        body: opts[:body].to_json,
        request_method: request_method,
        endpoint: path,
        jwt: opts[:token],
      )

      client.perform
    end

    def auth_uri?
      uri.request_uri.include?('auth')
    end

    # Full Url
    #
    # @return [String]
    def uri
      URI.parse(base_url + endpoint)
    end

    def missing_argument(key)
      raise ArgumentError, "Please supply a #{key.to_s}"
    end
  end
end

class Maxwell::UnauthorizedRequest < StandardError
end

class Maxwell::UnexpectedResponseBody < StandardError
end
