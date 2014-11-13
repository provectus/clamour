require 'active_support/core_ext/object'
require 'active_support/core_ext/array'

class Clamour::Registry

  # @return [Hash<Set<Class>>] store handler classes
  attr_reader :handlers

  # @return [Hash]
  attr_reader :message_classes

  def initialize(&block)
    @handlers = Hash.new { |mapping, type| mapping[type] = Set.new }
    @message_classes = Hash.new
    change(&block) if block_given?
  end

  def route(type, &block)
    raise ArgumentError.new('Something has to be routed') if type.blank?
    message_class = message_classes[type]
    found_handlers = handlers[type]
    if message_class.present? && found_handlers.present?
      found_handlers.each do |handler|
        block.call(handler, message_class)
      end
    else
      puts "Could not find message class or handler for #{type}"
    end
  end

  def change(&block)
    instance_eval(&block)
    self
  end

  def on(mappings = {})
    mappings.each do |message_class, handlers_list|
      raise ArgumentError.new("#{message_class} must include Clamour::Message") unless message_class < Clamour::Message
      Array.wrap(handlers_list).flatten.compact.each do |handler|
        raise ArgumentError.new("Handler #{handler} must be a class") unless handler.is_a?(Class)
        message_type = message_class.type
        message_classes[message_type] = message_class
        handlers[message_type].add(handler)
      end
    end
  end
end
