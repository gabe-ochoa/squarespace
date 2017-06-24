require 'Squarespace'

module Squarespace
  class Configuration
    attr_accessor :api_url, :api_key, :app_name

    def initialize(options)
      self.api_url = options[:api_url] || "https://api.squarespace.com"

      # No default values
      self.app_name = options[:app_name]
      self.api_key = options[:api_key]
    end
  end
end
