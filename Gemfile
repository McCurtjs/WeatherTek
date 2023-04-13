source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
# gem 'webpacker', '~> 5.0'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  #gem 'capybara', '>= 3.26'
  #gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  #gem 'webdrivers'
  gem 'rspec', '~> 3.12'
  gem 'timecop', '~> 0.9'
  gem 'rails-controller-testing', '~> 1.0' # needed for "assigns" in controller spec
  gem 'webmock', '~> 3.18'
end

group :test, :development do
  gem 'rspec-rails', '~> 6.0'
end

# Geolocation gem for converting address queries into locations (and zip codes)
gem 'geocoder', '~> 1.8.1'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# note: there is apparently a bug in bundler for 64 bit Ruby 3.1.x that makes it so no platform switch matches
#       leaving blank to fall-back to auto-resolve
gem 'tzinfo-data' # , platforms: [:mingw, :mswin, :x64_mingw, :jruby] #

# Bundler wants to update this, but while it's a dependency of rails, it's completely irrelevant here.
# Specifying old version to try and prevent an update becuase this gem takes hours to build for some reason.
gem 'nokogiri', '=1.14.2'
