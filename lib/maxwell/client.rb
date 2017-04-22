require 'net/http'
require 'uri'

module Matic
  class Client
    class << self
      attr_accessor :base_url,
                    :token
    end

    attr_reader :base_url,
                :token,
                :post_body,
                :request_method,
                :api_endpoint

    def initialize(opts = {})
      @base_url       = Maxwell::Client.base_url || opts.fetch(:base_url) { missing_argument(:base_url) }
      @token          = Maxwell::Client.token || opts.fetch(:token) { nil }
      @post_body      = opts.fetch(:post_body, "")
      @request_method = opts.fetch(:request_method) { :get }
      @endpoint   = opts.fetch(:endpoint) { missing_argument(:endpoint) }
    end

    def self.get(path)
      perform(path, :get)
    end

    def self.post(path, body)
      perform(path, :post, body: body)
    end

    def self.put(path, body, opts = {})
      perform(path, :put, body: body)
    end

    def self.delete(path, body = nil)
      perform(path, :delete, body: body)
    end

    def perform
      http = Net::HTTP.new(uri.host, uri.port)
      klass = "Net::HTTP::#{request_method.to_s.capitalize}"

      request = Object.const_get(klass).new(uri.request_uri)

      case method
      when :post, :put, :patch, :delete
        request.body = post_body
      end

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      if token.nil?
        request['Authorization'] = "Bearer #{jwt}"
      else
        request['Authorization'] = "Token #{token}"
      end

      request['Content-Type'] = 'application/json'
      request['Accept'] = 'application/vnd.himaxwell.com; version=1,application/json'

      http.request(request)
    end

    private

    def self.perform(path, request_method, opts = {})
      client = ::Maxwell::Client.new(
        post_body: opts[:body],
        request_method: request_method,
        endpoint: path,
      )

      client.perform
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

class Maxwell::UnexpectedResponseBody < StandardError
end
