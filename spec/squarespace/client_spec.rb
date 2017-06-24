require 'spec_helper'
require 'faraday'

describe Squarespace::Client do

  test_configuration

  let(:client) { Squarespace::Client.new }
  let(:private_client) { client.instance_eval {  } }

  context 'For the Squarespace API' do
    it 'create a connection to squarespace' do
      test_url = 'https://some_url.com'
      expect(Faraday).to receive(:new).with(
        url: 'https://some_url.com',
        ssl: true)
      client.send('connection', test_url)
    end

    it 'make a GET request to the sqaurespace api' do
      test_route = '/some/test/route'
      test_method = 'GET'
      expect(Faraday).to receive(:get).with(test_method, test_route)

      client.commerce_request(test_method, test_route)
    end

    it 'make a POST request with a json body to the sqaurespace api' do
      expect(client.commerce_request('POST', '/some/test/route', body = { "test": "body" }))
    end
  end

  context 'For the Squarespace Commerce API' do

    it 'have an API version number' do
      expect(Squarespace::Client::COMMERCE_API_VERSION).to be_a Float
      expect(Squarespace::Client::COMMERCE_API_VERSION).to be > 0
    end

    it 'set the commerce api url' do
      expect(client.commerce_url).to eq 'https://api.squarespace.com/0.1/commerce/orders'
    end

    it 'get a batch of orders' do
      orders = client.get_orders
      expect(orders.count).to be 3
    end
  end
end
