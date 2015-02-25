source 'https://rubygems.org'

# A Rails project
gem 'rails', '~>4.1'
gem 'blacklight-hierarchy', :git => "https://github.com/aploshay/blacklight-hierarchy.git", :branch => "blacklight_470"

# This is a Hydra head
gem 'hydra', '~> 6.1'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem "bootstrap-sass"
gem "devise"
gem "devise-guests", "~> 0.3"
gem 'omniauth'
gem 'omniauth-cas', :git => "https://github.com/cjcolvar/omniauth-cas.git"

group :development, :test do
  gem 'database_cleaner', git: 'https://github.com/atomical/database_cleaner', branch: 'adding_support_for_active_fedora_orm'
  gem "rspec-rails"
  gem "spring-commands-rspec"
  gem "guard-rspec"
  gem "capybara"
  gem "launchy"
  gem "factory_girl_rails"
  gem "jettywrapper"
end

# --- roo Gem ---
# Roo implements read access for all spreadsheet types and read/write access
# for Google spreadsheets. It can handle * OpenOffice * Excel *
# Google spreadsheets * Excelx * LibreOffice * CSV
gem "roo"
