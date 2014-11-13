class Clamour::Configuration::RabbitMqConfiguration
  include Clamour::Configuration::Base

  attribute :host, String, default: 'localhost'
  attribute :port, Fixnum, default: 5672
  attribute :user, String, default: 'guest'
  attribute :pass, String, default: 'guest'
  attribute :vhost, String, default: '/'
end
