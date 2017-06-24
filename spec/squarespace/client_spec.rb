require 'spec_helper'

describe Squarespace::Client do

  test_configuration

  let(:client) { Squarespace::Client.new }

  context 'For the Squarespace Commerce API' do

    it 'has an API version number' do
      expect(Squarespace::Client::COMMERCE_API_VERSION).to be_a Float
      expect(Squarespace::Client::COMMERCE_API_VERSION).to be > 0
    end

    it 'set the commerce api url' do
      expect(client.commerce_url).to eq 'https://api.squarespace.com/0.1/commerce/orders'
    end
  end
end
