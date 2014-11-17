# Clamour

Fancy messaging library for Ruby. It could, and should be used as a basis for asynchronous systems written in Ruby.
It uses [RabbitMQ](http://www.rabbitmq.com/) as a transport mechanism, and [Sidekiq](http://mperham.github.io/sidekiq/)
as a substrate to run message handlers.

## Installation

Add this line to your application's Gemfile:

```
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

## Usage

### Send a message

`Clamour::Message` is just a fancy hash serialized into 
JSON (using fabulous [Oj](https://github.com/ohler55/oj) gem) to be sent over RabbitMQ.
A message has a special attribute `_type` which distinguishes different
messages, and is added to a hash of message attributes. By default it is set to a snake cased,
dot delimited message class name. For example,

```
class Foo::Blah
  include Clamour::Message
  attribute :bar, String
end
foo = Foo::Blah.new(bar: 'baz')
Oj.dump(foo, mode: :compat)
# => {"_type":"foo.blah","bar":"baz"}
```

To publish a message, call `#publish` on it. By default the method uses global configuration in `Clamour.configuration`.
If you want to publish the message to somewhere special, pass an additional parameter to call:

```
foo.publish
# is equal to
foo.publish(Clamour.configuration)
# but a call below is different:
foo.publish(white_rabbit_mq_configuration)
```

The method `#publish` here really wraps an original message into a message of class Clamour::Message::Sent.
Only latter is really serialized and sent over the wire. So, effectively `foo.publish` would send JSON like this:

```
{"_type":"clamour.message.sent","payload":{"_type":"foo.blah","bar":"baz"}}
```

To set attributes, please, see documentation on [Virtus](https://github.com/solnic/virtus). If you intend to use
more complex object as an attribute value than a String, Fixnum, or Boolean, make sure the value can be serialized to JSON.
You can check it by doing something like this:
```
complex_object = ExtraComplexObject.new
Oj.dump(complex_object, mode: :compat)
```
For specific criteria making an object serializable, refer to [Oj](https://github.com/ohler55/oj) documentation.

### Receive a message

To decide what action should be run when a message comes, `Clamour::Registry` is used.
Effectively it maps message type to an array of handler classes.

To register a handler for a message one could use method `#on`:

```
Clamour.registry.on Foo::Blah => Foo::Blah::Receive
```

or employ a shortcut for mass-registration:

```
Clamour.registry.change do
  on Foo::Blah => Foo::Blah::Receive
  on Rabbit::White::Appeared => Rabbit::White::Follow
end
```

Handler registration could be put inside Rails initializer.

`Clamour::Bus#subscribe` gets every JSON delivery from RabbitMQ, and sends it to a provided block.
Registry is then used to determine what handler to invoke:

```
bus.subscribe do |delivered_hash|
  message_type = delivered_hash[:_type]
  registry.route(message_tye) do |handler_class, message_class|
    # Instantiate handler and pass message
  end
end
```

### Do something

An actual handler must run independently of the subscription process. For this few instruments could be used.
Clamour offloads handler running to Sidekiq. The previous code example effectively turns into

```
bus.subscribe do |delivered_hash|
  message_type = delivered_hash[:_type]
  registry.route(message_tye) do |handler_class, message_class|
    handler_class.perform_async(message_class.new(delivered_hash) # Kind of
  end
end
```

Real code is different, because of fancy fractal structure of the library: a message that you publish really is wrapped
inside `Clamour::Message::Sent`, and intercepted later by a handler of class `Clamour::Message::Receive`. The latter
routes wrapped message to an actual handler. You do not have to worry about it though.

A handler is a class that implements method `on_message(message)`, and includes module `Clamour::Handler`. You should expect `message` argument to
be an instance of the message class that you set in registry. For a registry

```
Clamour.registry.change do
  on Messaging::Foo::Done => Messaging::Blah::Do
end

class Messaging::Blah::Do

  # @param [Messaging::Foo::Done] message
  def on_message(message)
    # Do Something
  end
end
```

### And now all together

If you use the gem inside a Rails application, create an initializer, for example in
"config/initializers/clamour.rb" to set up Clamour to accept message `Messaging::Foo::Done` and pass it to a handler
`Messaging::Blah::Do`:

```
require 'clamour'

Clamour.configure do |config|
 config.exchange = 'special'
 # And other changes to default configuration
end

Clamour.registry.change do 
 on Messaging::Foo::Done => Messaging::Blah::Do
end
```

Then you have to start a subsription process. If you use Rails, Sidekiq, and Foreman,
all you need to do is to add a line to your Procfile:

```
subscriber: bundle exec rake clamour:subscribe
```

If the technological stack is different, you could figure out what to do just by looking at `clamour:subscribe`
rake task source code.

## TODO

* More testing.
* Scheduled messages: send message in the future.

## Contributing

1. Fork it ( https://github.com/provectus/caruso/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
