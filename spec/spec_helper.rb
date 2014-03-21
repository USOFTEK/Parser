require "bundler/setup"
Bundler.setup

require "rspec"
require "rspec/mocks"
require "json"
require "mycra"
require "mongoid-rspec"
Mongoid.load!("#{File.dirname(File.expand_path(__FILE__))}/support/rspec_mongoid_session.yml", :test)

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'rr'

RSpec.configure { |config|
	config.mock_with :rspec
	config.before :each do
		Mongoid.purge!
	end
	config.include Mongoid::Matchers, type: :model
}