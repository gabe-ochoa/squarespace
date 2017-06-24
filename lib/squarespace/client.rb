require 'Squarespace'
require 'Squarespace/configuration'
require 'faraday'
require 'json'

module Squarespace
  class Client
    attr_reader :commerce_url

    def initialize(options = {})
      @commerce_url = "#{Squarespace.configuration.api_url}/commerce/orders"
    end
  end
end
