require 'active_support/core_ext/hash'
require 'active_support/hash_with_indifferent_access'

# Unpack message and reroute it using the same {Clamour::Subscription}.
class Clamour::Message::Receive
  include Clamour::Handler

  # @param [Clamour::Message::Sent] wired
  # @param [Clamour::Subscription] subscription
  def self.perform(wired, subscription)
    attributes = ActiveSupport::HashWithIndifferentAccess.new(wired.payload)
    type = attributes[:_type]
    subscription.route(type, attributes)
  end
end
