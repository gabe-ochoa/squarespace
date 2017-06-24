# SquareSpace Commerce API

Ruby gem for interacting with the Squarespace API.

## Installation

Add this line to your application's Gemfile:

    gem 'squarespace'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install squarespace


# Example usage

## Configuration

    Squarespace.configure(
      app_name: 'YOUR_APP_NAME'
      app_secret: 'YOUR_CLIENT_SECRET'
    )

## Initializing the client

    client = Squarespace::Client.new

# Testing

`bundle exec rspec`

