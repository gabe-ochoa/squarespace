require 'Squarespace/client'
require 'Squarespace/configuration'
require 'Squarespace/version'

module Squarespace
  API_VERSION = 0.1

  def self.configuration
    @configuration
  end

  def self.configure(options = {})
    @configuration = Configuration.new(options)
    yield(configuration) if block_given?
    self.configuration
  end
end
