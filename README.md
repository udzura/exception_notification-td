# exception_notification-td

[![wercker status](https://app.wercker.com/status/7d390b46fd0fcea4e4aabc10f1a1b240/m "wercker status")](https://app.wercker.com/project/bykey/7d390b46fd0fcea4e4aabc10f1a1b240)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'exception_notification-td'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install exception_notification-td

## Usage

In Rails, first set up normal [td config](https://github.com/treasure-data/td-logger-ruby#configuration) and then:

```ruby
# in config/environments/#{env}.rb
config.middleware.use ExceptionNotification::Rack,
  td: {
    table_name: "#{Rails.env}_exceptions",
  }
```

In some other rack apps, you need to set more options:

```ruby
use ExceptionNotification::Rack,
  td: {
    table_name: "#{env}_exceptions",
    database: "yourdb",
    apikey: "deadbeaf12345678"
  }
```

## Contributing

1. Fork it ( https://github.com/udzura/exception_notification-td/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
