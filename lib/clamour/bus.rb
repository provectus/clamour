require 'amqp'
require 'active_support/core_ext/hash'
require 'active_support/hash_with_indifferent_access'
require 'oj'

class Clamour::Bus

  class WrongContentTypeError < RuntimeError
    # If not JSON.
  end

  # @return [Clamour::Configuration]
  attr_reader :configuration

  # @return [Hash]
  attr_reader :connection_settings

  # @return [String]
  attr_reader :exchange_name

  # @return [Logger]
  attr_reader :logger

  # @param [Clamour::Configuration] configuration
  def initialize(configuration = Clamour.configuration)
    @configuration = configuration
    @connection_settings = configuration.rabbit_mq.to_hash
    @exchange_name = configuration.exchange
    @logger = configuration.logger
  end

  # @param [Clamour::Message] message
  def publish(message)
    if EM.reactor_running?
      em_publish(message)
    else
      EM.run do
        em_publish(message) do
          EM.stop
        end
      end
    end
  end

  def subscribe(&block)
    if EM.reactor_running?
      em_subscribe(&block)
    else
      EM.run do
        em_subscribe(&block)
      end
    end
  end

  # @param [Clamour::Message] message
  def em_publish(message, &block)
    logger.debug "Message #{message.inspect} is going to be published"
    if configuration.enable_connection?
      AMQP.connect(connection_settings) do |connection|
        AMQP::Channel.new(connection) do |channel|
          channel.fanout(exchange_name, durable: true) do |exchange|
            options = { content_type: 'application/json' }
            exchange.publish(dump_json(message), options) do
              logger.debug "Message #{message.inspect} is published to #{exchange_name}"
              connection.disconnect do
                block.call if block_given?
              end
            end
          end
        end
      end
    else
      logger.debug "Connection is disabled. Message #{message.inspect} is not really published"
      block.call if block_given?
    end
  end

  def em_subscribe(&block)
    raise ArgumentError.new('You have to provide a block') unless block_given?

    if configuration.enable_connection?
      AMQP.connect(connection_settings) do |connection|
        before_shutdown do
          connection.close do
            EM.stop
          end
        end

        AMQP::Channel.new(connection) do |channel|
          channel.fanout(exchange_name, durable: true) do |exchange|
            EM.schedule do
              channel.queue('', exclusive: true) do |queue|
                queue.bind(exchange).subscribe do |header, delivery|
                  message_hash =
                      case header.content_type
                        when 'application/json'
                          ActiveSupport::HashWithIndifferentAccess.new(load_json(delivery))
                        else
                          raise WrongContentTypeError.new("Got #{delivery.inspect} for content type #{header.content_type}")
                      end
                  logger.debug "Got hash #{message_hash}"
                  block.call(message_hash)
                end
              end
            end
          end
        end
      end
    else
      logger.info 'Connection is disabled. Doing nothing...'
      before_shutdown { EM.stop }
    end
  end

  # Do something gentle on SIGINT
  def before_shutdown(&block)
    Signal.trap('INT') do
      logger.info 'Shutting down on SIGINT...'
      block.call if block_given?
    end
  end

  # @param [Clamour::Message] message
  # @return [String]
  def dump_json(message)
    Oj.dump(message, mode: :compat)
  end

  # @param [String] json
  # @return [Hash]
  def load_json(json)
    Oj.load(json)
  end
end
