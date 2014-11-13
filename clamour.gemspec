# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'clamour/version'

Gem::Specification.new do |spec|
  spec.name          = 'clamour'
  spec.version       = Clamour::VERSION
  spec.authors       = ['Sergey Ukustov']
  spec.email         = ['sergey@ukstv.me']
  spec.summary       = %q{Fancy messaging library}
  spec.description   = %q{Fancy messaging library for Ruby}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'amqp'
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'oj'
  spec.add_runtime_dependency 'virtus'
  spec.add_runtime_dependency 'mono_logger'
  spec.add_runtime_dependency 'sidekiq'

  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
