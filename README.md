# Clamour

Fancy messaging library for Ruby. It could, and should be used as a basis for asynchronous systems written in Ruby.
It uses [RabbitMQ](http://www.rabbitmq.com/) as a transport mechanism, and [Sidekiq](http://mperham.github.io/sidekiq/)
as a substrate to run message handlers.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clamour'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clamour

## Configuration

Configuration of the messaging system is contained in an instance of `Clamour::Configuration` class.
You could instantiate it using a hash of parameters:

```
configuration = Clamour::Configuration.new(logger: MonoLogger.new(STDERR), enable_connection: false)
```

or you could use accessors:

```
configuration = Clamour::Configuration.new
configuration.exchange = 'com.example.exchange'
```

If you intend to use the default Clamour configuration stored in `Clamour.configuration`, you could use a shortcut:

```
Clamour.configure do |config|
    config.rabbit_mq.host = '127.0.0.1'
    config.rabbit_mq.user = 'admin'
    config.rabbit_mq.pass = 'Ad$1n'
    config.exchange = 'com.example.exchange'
end
```

You could put configuration code like this in a Rails initializer.

NB. By default connection to RabbitMQ is disabled when Rails is in test mode.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/caruso/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
