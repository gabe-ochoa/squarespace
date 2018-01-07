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
      @logger = Logger.new(STDOUT)
      @logger.level = options.delete('log_level') || 'INFO'
      @config = Squarespace::Config.new(options)
      @commerce_url = "#{@config.api_url}/#{COMMERCE_API_VERSION}/commerce/orders"
    end

    def get_order(id)
      order_response = commerce_request('get', id.to_s)
      logger.debug("Order response: #{order_response.body}")
      Order.new(JSON.parse(order_response.body))
    end

    def get_orders(fulfillment_status = nil)
      if fulfillment_status.nil?
        order_response = commerce_request('get')
      else
        # binding.pry
        order_response = commerce_request('get', '', {}, 
          {"fulfillmentStatus"=>fulfillment_status.upcase})
      end

      logger.debug("Order response: #{order_response.body}")
      Order.new(JSON.parse(order_response.body))
    end

    def get_pending_orders
      get_orders('pending')
    end

    def get_fulfilled_orders
      get_orders('fulfilled')
    end

    def fulfill_order(order_id, shipments, send_notification=true)
      # fulfill_order(string, array[hash], boolean)
      #
      # Shipment array example:
      # 
      # [{
      #   tracking_number: 'test_tracking_number1',
      #   tracking_url: 'https://tools.usps.com/go/TrackConfirmAction_input?qtc_tLabels1=test_tracking_number2',
      #   carrier_name: 'USPS',
      #   service: 'ground'
      # },{
      #   tracking_number: 'test_tracking_number2',
      #   tracking_url: '',
      #   carrier_name: 'USPS',
      #   service: 'prioritt'
      # }]

      shipments_arry = []
      
      shipments.each do |shipment|
        shipments_arry << {
          "carrierName": shipment[:carrier_name],
          "service": shipment[:service],
          "shipDate": Time.now.iso8601,
          "trackingNumber": shipment[:tracking_number],
          "trackingUrl": shipment[:tracking_url]
        }
      end
      
      request_body = {
        "shipments": shipments_arry,
        "shouldSendNotification": send_notification
      }
      
      response = commerce_request('get', "#{order_id}/fulfillments", {}, {}, request_body)

      response.success?
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
