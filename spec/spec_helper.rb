require 'rubygems'
require 'spork'
require 'sidekiq'

require 'coveralls'
Coveralls.wear!

Spork.prefork do
  ENV['RAILS_ENV'] ||= 'test'

  require File.expand_path('../dummy/config/environment.rb', __FILE__)

  require 'rspec/rails'
  require 'database_cleaner'
  require 'pry'
  require 'rediska'

  Dir[File.expand_path('../../lib/**/*.rb', __FILE__)].each { |f| require f }
  Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

  RSpec.configure do |config|
    config.mock_with :rspec

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

    config.after(:suite) do
      FileUtils.rm_rf(File.expand_path('../test.sqlite3', __FILE__))
    end
  end
end

def test_request
  if ActionController::TestRequest.respond_to?(:create)
    ActionController::TestRequest.create
  else
    ActionController::TestRequest.new
  end
end

def parse_xml(response)
  xml = response.body.gsub('type="symbol"', '')
  Hash.from_xml(xml)['hash']
end
