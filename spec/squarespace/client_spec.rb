require 'spec_helper'
require 'faraday'
require 'json'
require 'timecop'

describe Squarespace::Client do

  let(:client) { Squarespace::Client.new(app_name: app_name, api_key: api_key) }
  let(:private_client) { client.instance_eval {  } }
  let(:api_url) { 'https://api.squarespace.com' }
  let(:app_name) { 'test_app' }
  let(:api_key) { 'test_key' } 
  let(:base_commerce_url) { "#{api_url}/0.1/commerce/orders" }
  let(:order_id) { '585d498fdee9f31a60284a37' }

  context 'For the Squarespace API' do
    it 'create a connection to squarespace' do
      test_url = 'https://some_url.com'
      expect(Faraday).to receive(:new).with(url: 'https://some_url.com')
      client.send('connection', test_url)
    end

    it 'make request to the sqaurespace api' do
      test_route = '/some/test/route'
      test_method = 'GET'
      expect_any_instance_of(Faraday::Connection).to receive(:get)

      client.commerce_request(test_method, test_route)
    end
  end

  context 'For the Squarespace Commerce API' do
    it 'have an API version number' do
      expect(Squarespace::Client::COMMERCE_API_VERSION).to be_a Float
      expect(Squarespace::Client::COMMERCE_API_VERSION).to be > 0
    end

    it 'set the commerce api url' do
      expect(client.commerce_url).to eq base_commerce_url
    end

    it 'get an order' do
      stub_faraday_request(stub_order_object, 'get', order_id)

      order = client.get_order(order_id)
      expect(order.lineItems.count).to be 1
    end

    it 'get a batch of orders' do
      stub_faraday_request(stub_orders_object, 'get')

      orders = client.get_orders
      expect(orders.result.count).to be 2
    end

    it 'get a batch of orders that is status PENDING' do
      stub_faraday_request(stub_pending_orders_object, 'get', 
        '', {}, {"fulfillmentStatus"=>"PENDING"})

      orders = client.get_pending_orders
      expect(orders.result.count).to be 2
      orders.each do |order|
        expect(order.fulfillmentStatus).to eq 'PENDING'
      end
    end

    it 'get a batch of orders that is status FULFILLED' do
      stub_faraday_request(stub_pending_orders_object, 'get', 
        '', {}, {"fulfillmentStatus"=>"FULFILLED"})

      orders = client.get_fulfilled_orders
      expect(orders.result.count).to be 2
      orders.each do |order|
        expect(order.fulfillmentStatus).to eq 'FULFILLED'
      end
    end

    it 'parises the response body as json' do
      valid_body = "{\"valid\":\"json\"}"
      parsed_body = client.parse_commerce_response_body(valid_body)

      expect(parsed_body['valid']).to eq 'json'
    end

    it 'errors gracefully when parising the response body as json' do
      invalid_body = '{\"invalid\" \"json\"}'
      expect{ client.parse_commerce_response_body(invalid_body) }.to raise_error(JSON::ParserError)
    end

    it 'checks the response code' do
      expect{ client.check_response_status(200) }.not_to raise_error(Squarespace::Errors::BadRequest)
    end

    it 'checks the response code and raises when there is a bad request' do
      expect{ client.check_response_status(400) }.to raise_error(Squarespace::Errors::BadRequest)
    end

    it 'checks the response code and raise an exception when there are authentication errors' do
      expect{ client.check_response_status(401) }.to raise_error(Squarespace::Errors::Unauthorized)
    end

    it 'checks the response code and raises an exception when not found' do
      expect{ client.check_response_status(404) }.to raise_error(Squarespace::Errors::NotFound)
    end

    it 'checks the response code and raises an exception when an incorrect method was called' do
      expect{ client.check_response_status(405) }.to raise_error(Squarespace::Errors::MethodNotAllowed)
    end

    it 'checks the response code and raises when there have been too many requests' do
      expect{ client.check_response_status(429) }.to raise_error(Squarespace::Errors::TooManyRequests)
    end

    it 'fulfill an order' do
      Timecop.freeze
      body_fixture = JSON.parse(load_fixture('spec/fixtures/fulfill_order_body.json'), symbolize_names: true)
      body_fixture[:shipments].each do |s|
        s[:shipDate] = Time.now.utc.iso8601
      end

      shipments = [{
        tracking_number: 'test_tracking_number1',
        tracking_url: 'https://tools.usps.com/go/TrackConfirmAction_input?qtc_tLabels1=test_tracking_number2',
        carrier_name: 'USPS',
        service: 'ground'
      },{
        tracking_number: 'test_tracking_number2',
        tracking_url: nil,
        carrier_name: 'USPS',
        service: 'priority'
      }]
      send_notification = true

      stub_faraday_request(stub_fulfill_order_object, 
        'post', "#{order_id}/fulfillments",
        {"Content-Type"=>"application/json","Authorization"=>"Bearer test_key"},
        {}, body_fixture.to_json)

      client.fulfill_order(order_id, shipments, send_notification)
    end
  end
end
