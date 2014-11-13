require 'active_support/inflector'
require 'active_support/concern'
require 'active_support/dependencies/autoload'
require 'virtus'

# What is sent over the wire.
module Clamour::Message
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload
  include Virtus.module

  autoload :Sent
  autoload :Receive

  module ClassMethods
    # Voluntarily set message type.
    #
    # @param [String] new_value
    # @example
    #     class Parcel < Clamour::Message
    #       of_type 'snail.mail'
    #     end
    def of_type(new_value = nil)
      @type = new_value.to_s
    end

    # Message type. By default it is snake cased class name.
    #
    # @return [String]
    def type
      @type ||= ActiveSupport::Inflector.underscore(to_s).gsub('/', '.')
    end
  end

  # It is highly unlikely someone would use `_type` as a name, so we use it to store service information,
  # namely message type.
  attribute :_type, String, default: ->(message, _) { message.class.type }

  def publish(configuration = Clamour.configuration)
    bus = Clamour::Bus.new(configuration)
    sent_message = Clamour::Message::Sent.new(payload: self)
    bus.publish(sent_message)
  end
end
