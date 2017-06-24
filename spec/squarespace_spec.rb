require 'spec_helper'

describe Squarespace do
  it 'has a version number' do
    expect(Squarespace::VERSION).to_not be nil
  end

  it 'has an API version number' do
    expect(Squarespace::API_VERSION).to be_a Float
    expect(Squarespace::API_VERSION).to be > 0
  end
end
