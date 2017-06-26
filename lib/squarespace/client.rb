require 'Squarespace'
require 'Squarespace/configuration'
require 'Squarespace/order'
require 'faraday'
require 'json'

module Squarespace
  class Client
    attr_reader :commerce_url

    COMMERCE_API_VERSION = 0.1

    def initialize(options={})
      @commerce_url = "#{Squarespace.configuration.api_url}/#{COMMERCE_API_VERSION}/commerce/orders"
    end

    def get_orders
      order_response = commerce_request('get')
      Order.new(order_response.body)
    end

    def commerce_request(method, route='', headers={}, parameters={}, body=nil)
      response = connection(commerce_url).send(method.downcase) do |req|
        if method.eql?('post')
          req.headers['Content-Type'] = 'application/json'
        end
        parameters.each { |k,v| req.params["#{k}"] = v } if parameters.any?
        headers.each { |k,v| req.headers["#{k}"] = v } if headers.any?

        # We always need an Authorization header
        req.headers['Authorization'] = "Bearer #{Squarespace.configuration.api_key}"
        req.url route
        req.body = body unless body.nil?
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
