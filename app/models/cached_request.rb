
##
# Basic class to wrap Net/HTTP calls in a cache.
class CachedRequest

  ##
  # Exception class to raise when the given HTTP call fails
  class CachedHttpGetException < StandardError
    def initialize(response = nil)
      @response = response
      super "Failed HTTP Query"
    end

    def response
      @response
    end
  end

  require 'uri'
  require 'net/http'

  ##
  # Initializes the request object with preparation and control parameters
  #
  # @param [Hash] params
  # @option params [String] :uri_string - the full endpoint for the request
  # @option params [String] :cache_key - the key to use to cache this request
  # @option params [String] :expires_in - duration to expire the cache in
  #                                       (default: 30.minutes)
  def initialize(params)
    @uri_string = params[:uri_string]
    @cache_key = params[:cache_key]
    @expires_in = params[:expires_in] || Rails.application.config.default_cache_duration
  end

  ##
  # @return [Boolean|Nil] true if the last request was read from the cache. Can
  # be nil if the request has not yet been used.
  def cached
    @cached
  end

  ##
  # Uses the initialized parameters to send a GET request to the remote URI, or
  # read from the cache if the same request has already been made within the
  # given time limit.
  #
  # @raise [CachedHttpGetException] in the event the remote request fails
  # @return [String] the body of the request
  def get
    @cached = true

    Rails.cache.fetch(@cache_key, expires_in: @expires_in) do
      @cached = false

      uri = URI(@uri_string)
      @result = Net::HTTP.get_response(uri)

      raise CachedHttpGetException.new(@result) unless @result.is_a? Net::HTTPSuccess

      @result.body
    end
  end

  ##
  # @return [Net::HTTP::Response] the full response of the most recent request
  def result
    @result
  end

end
