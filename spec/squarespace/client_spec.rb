require 'spec_helper'
require 'faraday'
require 'json'

describe Squarespace::Client do

  test_configuration

  let(:client) { Squarespace::Client.new }
  let(:private_client) { client.instance_eval {  } }
  let(:base_commerce_url) { "https://api.squarespace.com/0.1/commerce/orders" }
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

    it 'gets an order' do
      stub_faraday_request(stub_order_object, 'get', "#{base_commerce_url}/#{order_id}")

      order = client.get_order(order_id)
      expect(order.lineItems.count).to be 1
    end

    it 'gets a batch of orders' do
      skip('TODO')
      stub_faraday_request(stub_orders_object, 'get', '')

      orders = client.get_orders
      expect(orders.count).to be 2
    end

    it 'get a batch of orders that is status PENDING' do
      skip('TODO')
      stub_faraday_request(stub_pending_orders_object, 'get', '', )

      orders = client.get_unfulfilled_orders
      expect(orders.count).to be 2
      orders.each do |order|
        expect(order.fulfillmentStatus).to eq 'PENDING'
      end
    end

    it 'get a batch of orders that is status FULFILLED' do
      skip('TODO')
      stub_faraday_request(stub_fulfilled_orders_object, 'get', '')

      orders = client.get_fulfilled_orders
      orders.each do |order|
        expect(order.fulfillmentStatus).to eq 'FULFILLED'
      end
    end

    it 'fulfills an order' do
      skip('TODO')
      shipments = [{
        tracking_number: 'test_tracking_number1',
        tracking_url: 'https://tools.usps.com/go/TrackConfirmAction_input?qtc_tLabels1=test_tracking_number2',
        carrierName: 'USPS',
        service: 'ground'
      },{
        tracking_number: 'test_tracking_number2',
        tracking_url: '',
        carrierName: 'USPS',
        service: 'prioritt'
      }]

      stub_faraday_request(stub_order_object, 
        'get', 
        "#{base_commerce_url}/#{order_id}/fulfillments",
        {"Content-Type"=>"application/json","Authorization"=>"Bearer test_key"},
        {},
        load_fixture('spec/fixtures/fulfill_order_body.json')
        )

      expect(client.fulfill_order(order_id, shipments, send_notification)).to be true
    end
  end
end
