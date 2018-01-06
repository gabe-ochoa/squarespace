require 'Squarespace'
require 'Squarespace/configuration'
require 'Squarespace/order'
require 'faraday'
require 'json'
require 'logger'

module Squarespace
  class Client
    attr_reader :commerce_url, :logger

    COMMERCE_API_VERSION = 0.1

    def initialize(options={})
      @config = Squarespace::Config.new(options)
      @commerce_url = "#{@config.api_url}/#{COMMERCE_API_VERSION}/commerce/orders"
      @logger = Logger.new(STDOUT)
    end

    def get_order(id)
      order_response = commerce_request('get', id.to_s)
      logger.info("Order response: #{order_response.body}")
      Order.new(JSON.parse(order_response.body))
    end

    def commerce_request(method, route='', headers={}, parameters={}, body=nil)
      response = connection(@commerce_url).send(method.downcase) do |req|
        if method.eql?('post')
          req.headers['Content-Type'] = 'application/json'
        end
        parameters.each { |k,v| req.params["#{k}"] = v } if parameters.any?
        headers.each { |k,v| req.headers["#{k}"] = v } if headers.any?

        # We always need an Authorization header
        req.headers['Authorization'] = "Bearer #{@config.api_key}"
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
