# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'activerecord-amazon-timestream-adapter'
  s.version = '0.0.2'
  s.author = 'Francois Deschenes'
  s.email = 'fdeschenes@me.com'
  s.summary = 'ActiveRecord Amazon Timestream Adapter'
  s.homepage = 'https://github.com/fdeschenes/activerecord-amazon-timestream-adapter'
  s.license = 'MIT'

  s.files = Dir['MIT-LICENSE', 'README.md', 'lib/**/*']
  s.require_paths = ['lib']

  s.required_ruby_version = '~> 2.4'

  s.add_development_dependency 'bundler', '~> 1.3'

  s.add_dependency 'activerecord', '~> 4.2'
  s.add_dependency 'arel', '~> 6.0'
  s.add_dependency 'aws-sdk-core', '~> 3.0'
  s.add_dependency 'aws-sdk-timestreamquery', '~> 1.0'
end
