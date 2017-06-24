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
      connection(commerce_url).send(method.downcase) do |req|
        if method.eql?('post')
          req.headers['Content-Type'] = 'application/json'
        end
        req.url route
        req.body = body
      end
    end

    private

    def connection(url)
      Faraday.new(url: url) do |faraday|
        faraday.request  :url_encoded
        faraday.adapter  Faraday.default_adapter
      end
    end
  end
end
