require 'spec_helper'

describe Squarespace::Configuration do
  context 'the confgiuration' do
    it 'is present' do
      expect(test_configuration.nil?).to be false
    end

    it 'has an api_url' do
      expect(test_configuration.api_url).to eq('https://api.squarespace.com/')
    end

    it 'has an api_key' do
      expect(test_configuration.api_key).to eq('test_key')
    end

    it 'has an app_name' do
      expect(test_configuration.app_name).to eq('test_app')
    end
  end
end
