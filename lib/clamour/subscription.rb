class Clamour::Subscription
  # @return [Clamour::Configuration]
  attr_reader :configuration

  # @return [Logger]
  attr_reader :logger

  # @return [Clamour::Registry]
  attr_reader :registry

  # @param [Clamour::Configuration] configuration
  def initialize(configuration = Clamour.configuration, registry = Clamour.registry)
    @configuration = configuration
    @logger = configuration.logger
    @registry = registry
  end

  def perform
    bus.subscribe do |received_hash|
      type = received_hash[:_type]
      route(type, received_hash)
    end
  end

  # @param [String] type
  # @param [Hash] attributes
  def route(type, attributes)
    registry.route(type) do |handler_class, message_class|
      handler_class.perform(message_class.new(attributes), self)
    end
  end

  def bus
    @bus ||= Clamour::Bus.new(configuration)
  end
end
