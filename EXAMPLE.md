# End-to-end example

The first thing you need to do is to declare a message class, and a handler class.
Let's assume the handler writes a file in /tmp based on a message.

Here is a message, that is sent by an exquisitely sophisticated blog application:

```
require 'clamour'

module Blog
  module Post
    class Added
      include Clamour::Message
      
      attribute :name, String
      attribute :content, String
    end
  end
end
```

To publish it run in ruby console:

    message = Blog::Post::Added.new(name: 'My first blog post!', content: 'I am proud')
    message.publish
    
Make sure the command does not hang.

First, make sure the message is received where you expect it to be. Try to receive what is wired through the rabbitmq.
Open a terminal, and type:

    require 'clamour'
    bus = Clamour::Bus.new
    bus.subscribe do |delivery|
        puts delivery.inspect
    end
    
Next open another terminal, and publish the message as shown above. You should expect a message json to appear.

Then open another terminal, and start "subscription", i.e. process of enqueuing handler as a Sidekiq job:

    require 'clamour'
    Clamour::Subscription.new.perform
    
Then open yet another terminal, and run sidekiq there.

Now, if you publish the message again, you should see the handler as a sidekiq job, and a file in /tmp folder.

