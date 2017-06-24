require 'simplecov'
require 'webmock/rspec'
require 'pry'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'squarespace'

def test_configuration
  Squarespace.configure(
    app_name: 'test_app',
    api_key: 'test_key'
    )
end

def stub_faraday_request(return_object, method, url='', body=nil)
  request = double
  expect(request).to receive(:url).with(url)
  expect(request).to receive(:body).with(body)
  expect_any_instance_of(Faraday::Connection).to receive(method.to_sym)
    .and_yield(request)
    .and_return(return_object)
end

def stub_faraday_response(status, body)
  stub_response = object_double('response', body: body, status: status)
end

def stub_orders_object
  stub_faraday_response(200, load_json_fixture('spec/fixtures/orders_response.json'))
end

def load_json_fixture(path)
  JSON.parse(File.read(path))
end

RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.order = :random
  config.warnings = true
  config.color_mode = true
end
