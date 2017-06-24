require 'Squarespace'
require 'Squarespace/configuration'
require 'faraday'
require 'json'

module Squarespace
  class Client
    attr_reader :commerce_url

    COMMERCE_API_VERSION = 0.1

    def initialize(options={})
      @commerce_url = "#{Squarespace.configuration.api_url}/#{COMMERCE_API_VERSION}/commerce/orders"
    end

    def commerce_request(method, route=nil, body=nil)

    end


    private

    def connection(url)
      Faraday.new(url: url, ssl: true)
    end
  end
end
