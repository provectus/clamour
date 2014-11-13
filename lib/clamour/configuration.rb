require 'clamour/version'
require 'active_support/dependencies/autoload'
require 'mono_logger'

class Clamour::Configuration
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :RabbitMqConfiguration

  include Clamour::Configuration::Base

  attribute :rabbit_mq, RabbitMqConfiguration, default: RabbitMqConfiguration.new
  attribute :exchange, String, default: 'clamour.exchange'
  attribute :logger, Logger, default: :default_logger
  attribute :enable_connection, Boolean, default: :default_enable_connection

  # @return [Logger]
  def default_logger
    MonoLogger.new(STDERR)
  end

  # @return [Boolean]
  def default_enable_connection
    !(defined?(Rails) && Rails.env.test?)
  end

  # @return [Boolean]
  def enable_connection?
    enable_connection
  end
end
