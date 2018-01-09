module Squarespace
  class Config
    attr_reader :api_url, :api_key, :app_name

    def initialize(options)
      @api_url = options[:api_url] || "https://api.squarespace.com"

      # No default values
      @app_name = options[:app_name]
      @api_key = options[:api_key]
    end
  end
end
