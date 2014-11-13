require 'virtus'

module Clamour::Configuration::Base
  include Virtus.module

  # @return [Boolean]
  def eql?(other)
    other.respond_to?(:attributes) && attributes.eql?(other.attributes)
  end

  # @return [Fixnum]
  def hash
    attributes.hash
  end
end
