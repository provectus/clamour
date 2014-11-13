require 'clamour'

class Foo
  include Clamour::Message

  attribute :blah, String
end

class FooHandler
  include Clamour::Handler

  # @param [Foo] foo
  def on_message(foo)
    File.open('/Users/ukstv/Desktop/a.txt', 'w') do |f|
      f.puts Time.now.to_s
      f.puts foo.blah
      f.puts '----' * 10
    end
  end
end
