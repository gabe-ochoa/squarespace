require 'spec_helper'

describe Squarespace::Config do
  context 'the confgiuration' do
    let(:config) { Squarespace::Config.new(app_name: 'test_app', api_key: 'test_key') }

    it 'is present' do
      expect(config.nil?).to be false
    end

    it 'has an api_url' do
      expect(config.api_url).to eq('https://api.squarespace.com')
    end

    it 'has an api_key' do
      expect(config.api_key).to eq('test_key')
    end

    it 'has an app_name' do
      expect(config.app_name).to eq('test_app')
    end
  end
end
