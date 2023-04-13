require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WeatherTek
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #

    config.time_zone = "UTC"
    # config.eager_load_paths << Rails.root.join("extras")

    # Some custom configurations so we can specify the endpoint and formatting of
    # the weather API we're using, and to load the private API key.
    config.weather_api = OpenStruct.new(
      endpoint: 'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/',
      params: '?unitGroup=us&contentType=json&key=' + Rails.application.credentials.visualcrossing
    )

    # Default cache duration for cached requests
    config.default_cache_duration = 30.minutes
  end
end
