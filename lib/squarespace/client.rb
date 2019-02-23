require 'faraday'
require 'json'
require 'logger'
require 'time'


module Squarespace
  class Client
    attr_reader :commerce_url, :logger

    COMMERCE_API_VERSION = 0.1

    def initialize(options={})
      @logger = Logger.new(STDOUT)
      if ENV['LOG_LEVEL'].nil?
        @logger.level = options.delete('log_level') || 'INFO'
      else
        @logger.level = ENV['LOG_LEVEL']
      end
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
        order_response = commerce_request('get', '', {}, 
          {"fulfillmentStatus"=>fulfillment_status.upcase})
      end

      logger.debug("Order response: #{order_response.body}")
      check_response_status(order_response.status)
      parsed_body = parse_commerce_response_body(order_response.body)
      
      Order.new(parsed_body)
    end

    def parse_commerce_response_body(body)
      begin
        parsed_response = JSON.parse(body)
      rescue JSON::ParserError => e
        logger.error("Error parsing response body as JSON: #{body}")
        raise e
      end
      return parsed_response
    end

    def check_response_status(code)
      case code
      when 200
        return code
      when 400
        raise Squarespace::Errors::BadRequest
      when 401
        raise Squarespace::Errors::Unauthorized
      when 404
        raise Squarespace::Errors::NotFound
      when 405
        raise Squarespace::Errors::MethodNotAllowed
      when 429
        raise Squarespace::Errors::TooManyRequests
      else
        return code
      end
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
      #   tracking_url: nil,
      #   carrier_name: 'USPS',
      #   service: 'prioritt'
      # }]

      shipments_arry = []
      
      shipments.each do |shipment|
        shipments_arry << {
          "carrierName": shipment[:carrier_name],
          "service": shipment[:service],
          "shipDate": "#{Time.now.utc.iso8601}",
          "trackingNumber": shipment[:tracking_number],
          "trackingUrl": shipment[:tracking_url]
        }
      end
      
      request_body = {
        "shipments": shipments_arry,
        "shouldSendNotification": send_notification
      }
      
      commerce_request('post', "#{order_id}/fulfillments", {}, {}, request_body.to_json)
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
  
  class Errors
    class BadRequest < StandardError
      ;
    end
    class Unauthorized < StandardError
      ;
    end
    class NotFound < StandardError
      ;
    end
    class MethodNotAllowed < StandardError
      ;
    end
    class TooManyRequests < StandardError
      ;
    end
  end
end