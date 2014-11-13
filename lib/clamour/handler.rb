require 'sidekiq'
require 'active_support/concern'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'

module Clamour::Handler
  extend ActiveSupport::Concern

  included do
    include Sidekiq::Worker
  end

  module ClassMethods

    # Special thing for internal purposes only. Just implement +on_message(message)+ method.
    #
    # @param [Clamour::Message] message
    # @param [Clamour::Subscription] subscription
    def perform(message, subscription)
      perform_async(message.class.to_s, message.to_hash)
    end
  end

  # Like a usual Sidekiq job.
  #
  # @param [String] message_class_name
  # @param [Hash] message_attributes
  def perform(message_class_name, message_attributes)
    message = restore_message(message_class_name, message_attributes)
    on_message(message)
  end

  # @abstract You must use +on_message+ method to act on a message.
  # @param [Clamour::Message] message
  def on_message(message)
    raise NotImplementedError.new('You must override "on_message" method to act on a message')
  end

  protected

  # Deserialize message of Sidekiq-passed parameters.
  #
  # @param [String] message_class_name
  # @param [Hash] message_attributes
  # @return [Clamour::Message]
  def restore_message(message_class_name, message_attributes)
    message_class = message_class_name.constantize
    message_class.new(message_attributes)
  end

end
