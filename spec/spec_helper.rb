$LOAD_PATH.unshift(File.dirname(__FILE__))
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'shoulda-matchers'
require 'capybara/rails'
require 'capybara/rspec'
require 'database_cleaner'
require 'factory_girl_rails'

Rails.backtrace_cleaner.remove_silencers!

DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  
  config.after(:each, :type => :request) do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end
end
