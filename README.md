# SquareSpace Commerce API

Ruby gem for interacting with the SquareSpace Commerce API.

## Installation

Add this line to your application's Gemfile:

    gem 'squarespace-commerce'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install squarespace-commerce


# Example usage

## Configuration

    SquareSpace.configure(
      app_name: 'YOUR_APP_NAME'
      app_secret: 'YOUR_CLIENT_SECRET'
    )

## Initializing the client

    client = SquareSpace::Commerce::Client.new

# Testing

`bundle exec rspec`

