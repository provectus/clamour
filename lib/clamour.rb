require 'clamour/version'
require 'active_support/dependencies/autoload'

module Clamour
  extend ActiveSupport::Autoload

  autoload :Bus
  autoload :Configuration
  autoload :Handler
  autoload :Message
  autoload :Registry
  autoload :Message
  autoload :Subscription

  # Clamour-wide configuration.
  #
  # @return [Clamour::Configuration]
  def self.configuration
    @configuration ||= Clamour::Configuration.new
  end

  # Shortcut for Clamour-wide configuration.
  # @yield [Clamour::Configuration]
  #
  # @example
  #     Clamour.configure do |config|
  #       config.exchange = 'com.example.exchange'
  #       config.logger = MonoLogger.new(STDOUT)
  #     end
  # @see Clamour::Configuration
  def self.configure(&block)
    block.call(configuration) if block_given?
  end

  # Clamour-wide message handlers registry.
  #
  # @example To add handlers
  #     Clamour.registry.change do
  #       on Social::User::New => Social::User::Greeting::Send
  #     end
  # @see Clamour::Registry
  def self.registry
    @registry ||= Clamour::Registry.new do
      on Clamour::Message::Sent => Clamour::Message::Receive
    end
  end
end

require 'clamour/railtie' if defined?(Rails)
