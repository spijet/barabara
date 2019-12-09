# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'barabara/version'

Gem::Specification.new do |s|
  s.name     = 'barabara'
  s.version  = Barabara::VERSION
  s.date     = '2019-12-08'
  s.authors  = ['Serge Tkatchouk']
  s.summary  = 'Bar brains for standalone WMs'
  s.homepage = 'https://github.com/spijet/barabara'
  s.license  = 'MIT'

  s.files = Dir["Gemfile", "lib/**/*", "bin/*"]
  s.executables << 'barabara'
  s.platform = Gem::Platform::RUBY
  s.require_paths = ["lib"]
  s.bindir = 'bin'

  s.required_ruby_version = '>= 2.3'

  s.add_runtime_dependency 'wisper', '~> 2.0'
  s.add_runtime_dependency 'optimist', '~> 3.0.0'

  s.add_development_dependency 'bundler', '~> 2.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.requirements << 'lemonbar'
end
