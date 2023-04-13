##
# Forecast class to access and read data from the Weather API response.
class Forecast

  require 'uri'
  require 'net/http'

  ##
  # Initializes the Forecast instance with data read from the Weather API
  #
  # @param [String] location the location to look up the forecast for.
  # For caching, this location should be given in a high-level form. For this
  # project, we're going with a combination of city and zip code
  # (eg: "seattle-98101").
  #
  # @raise [CachedHttpGetException] in the event the remote request fails
  def initialize(location)
    uri_string = ENDPOINT + location + PARAMS

    request = CachedRequest.new(uri_string: uri_string, cache_key: location)
    json_string = request.get

    @cached = request.cached

    @data = JSON.parse(json_string, object_class: OpenStruct).freeze
  end

  ##
  # Returns whether or not the data for this forecast was read from the cache
  #
  # @return [Boolean] true if the data was cached, false if a net call was made
  def cached
    @cached
  end

  ##
  # Returns the daily data representing the current day
  #
  # @return [OpenStruct] weather data for the current day
  def current_day
    @data.days[current_day_index]
  end

  ##
  # Gets the index that points to the current day in the weather data.
  #
  # Because we're caching the data, it's theoretically possible a user could
  # access the service once before midnight, then again just after, before the
  # cache expires. In this case, choosing the first entry would show incorrect
  # data from the now previous day, so we want to make sure to move to the next
  # day's forecast.
  #
  # Note: for now we're assuming a cache time of less than 24 hours. If a longer
  # cache time was used, this would have to support moving beyond only the
  # second day.
  #
  # @return [Integer] 0 or 1
  def current_day_index
    return @current_day_index if @current_day_index.present?

    date_key = local_time.strftime('%Y-%m-%d')
    @current_day_index = 0

    if date_key != @data.days.first.datetime
      @current_day_index = 1
    end

    @current_day_index
  end

  ##
  # This function returns the block of data representing the current hour of the
  # current day.
  #
  # From testing the VisualCrossing weather API, I found the "currentConditions"
  # field to feel... inaccurate (shows temp: 67 in Seattle on a day with a max
  # of 52). But, the days.temp field is an average over the whole day, so comes
  # across as too cold. The hourly temperature seems much more accurate, so to
  # mitigate this issue we'll make sure to get the most up-to-date block of data
  # based on the current time in the local time zone we're checking for.
  #
  # @return [OpenStruct] weather data relating to the current hour
  def current_hourly_data
    current_day.hours[local_time.hour]
  end

  ##
  # @return [OpenStruct] all the data for the forecast
  def data
    @data
  end

  ##
  # Gets the current (system) time in UTC and transforms it to the local time
  # based on the time zone offset for the region the forecast is for.
  #
  # @return [Time] the current time in this forecast's local time zone
  def local_time
    @local_time ||= Time.current.time.in_time_zone(@data.tzoffset.to_f)
  end

  private

  ENDPOINT = Rails.application.config.weather_api.endpoint.freeze
  PARAMS = Rails.application.config.weather_api.params.freeze
end
