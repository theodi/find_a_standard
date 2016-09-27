require 'coveralls'
Coveralls.wear_merged!

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'find_a_standard'
require 'webmock/rspec'
require 'rack/test'

WebMock.allow_net_connect!

module RSpecMixin
  include Rack::Test::Methods
  def app
    FindAStandard::App
  end
end

RSpec.configure do |config|
  config.include RSpecMixin

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:each) do
    FindAStandard::Client.create_index
  end

  config.after(:each) do
    FindAStandard::Client.delete_index
  end

  config.order = :random
  Kernel.srand config.seed
end
