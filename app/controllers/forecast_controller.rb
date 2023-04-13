
##
# Forecast controller to manage endpoints for our routes
class ForecastController < ApplicationController

  ##
  # GET forecast/
  #
  # Index entry point for forecast controller.
  # Does nothing other than default, so left blank here.
  # def index ; end

  ##
  # POST search/:query
  #
  # Search entry point for resolving location queries from the main page.
  #
  # This handler redirects to the display page for a given location after
  # extracting a key from the given general case address provided by the user
  def search
    locations = Geocoder.search(query_params)

    # Check to make sure we can access the geocoder service first
    if locations.empty?
      redirect_to root_path, flash: {
        error: "Failed to query location service - did you remember to update
                the master.key file first?"
      }
    else
      # Transform the query into a location key with the form "seattle-98121"
      location_key = geolocation_to_post_key(locations.first)

      # If the resulting key is blank, we didn't have enough info in the
      # location result to do a search on.
      if location_key.blank?
        return redirect_to root_path, flash: {
          error: "Couldn't resolve the given location: \"#{query_params}\"."
        }
      end

      # By now, the location key should be in the format "seattle-98101" even if
      # the user entered, say, "Two Union Square, 601 Union St". Both work in
      # the weather api, but the former is better for caching.
      redirect_to forecast_path(query: location_key)
    end
  end

  ##
  # GET forecast/:query
  #
  # Show page entry point, takes a location from the URL params and queries the
  # Weather API to display its data.
  def show
    begin
      @forecast = Forecast.new(query_params)
    rescue CachedRequest::CachedHttpGetException => e
      redirect_to root_path, flash: {
        error: "Failed to load forecast data from Weather API - did you " +
          "remember to update the master.key file first? - #{e.response.inspect}"
      }
    end
  end

  private

  ##
  # Gets a simplified location code that can be both used to query the weather
  # API as well as a key for caching that result.
  #
  # TODO: for continued development, this should  be in a Location class to wrap
  # and extend Geocoder functionality, similar to the Forecast class, rather
  # than in the controller.
  #
  # @param [Geocoder::Result] geocoder_location - the single location we want to
  #                                               build a key for
  #
  # @return [String] a location key in the form "city-area_code"
  def geolocation_to_post_key(geocoder_location)
    location_key = geocoder_location.city

    if geocoder_location.postal_code.present?
      # Remove over-specificity for codes like 12345-6789 (we want the 5-digit)
      post_key = geocoder_location.postal_code.split('-').first

      location_key += "-#{post_key}"
    end

    # Replace spaces with URL-friendly underscores for things like foreign post
    # codes (such as "M3 4" in the UK) or cities like "New York".
    location_key.split(' ').join('_').downcase
  end

  ##
  # Use to separate query params from the request and ensure no extra data given
  #
  # @return [String] the query param for the search and show routes
  def query_params
    params.require(:query)
  end

end
