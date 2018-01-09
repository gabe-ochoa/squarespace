# SquareSpace Commerce API

[![Gem Version](https://badge.fury.io/rb/squarespace.svg)](https://badge.fury.io/rb/squarespace)

Ruby gem for interacting with the Squarespace API.

## Installation

Add this line to your application's Gemfile:

    gem 'squarespace'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install squarespace


# Example usage

## Initializing the client
```
client = Squarespace::Client.new(
  app_name: 'YOUR_APP_NAME'
  app_secret: 'YOUR_CLIENT_SECRET'
)
```
## Get an order
```
client.get_order(order_id)
```
## Get all orders
```
client.get_orders
```
## Get all orders with a specified fulfillment status
```
client.get_orders('pending')
client.get_orders('fulfilled')
client.get_orders('canceled')
```
## Fulfill an order
```
client.fulfill_order(order_id, shipments, send_notification)
```

	`shipments` is a hash array in the form of

```      
[{
  tracking_number: 'test_tracking_number1',
  tracking_url: 'https://tools.usps.com/go/TrackConfirmAction_input?qtc_tLabels1=test_tracking_number2',
  carrier_name: 'USPS',
  service: 'ground'
},{
  tracking_number: 'test_tracking_number2',
  tracking_url: nil,
  carrier_name: 'USPS',
  service: 'prioritt'
}]
``` 


# Testing

`bundle exec rspec`

