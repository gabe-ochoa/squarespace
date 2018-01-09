require 'squarespace/client'
require 'squarespace/configuration'
require 'squarespace/version'

module Squarespace

  def self.configuration
    @configuration
  end

  def self.configure(options = {})
    @configuration = Configuration.new(options)
    yield(configuration) if block_given?
    self.configuration
  end
end
