# frozen_string_literal: true

# Copyright (c) 2021 Steven Hoffman
# All rights reserved.

$LOAD_PATH.push ::File.expand_path('lib', __dir__)
require 'fustrate/rails/version'

::Gem::Specification.new do |s|
  s.name = 'fustrate-rails'
  s.version = ::Fustrate::Rails::VERSION
  s.authors = ['Steven Hoffman']
  s.required_ruby_version = '>= 2.7.0'

  s.summary = 'A few useful services and initializers.'
  s.homepage = 'https://github.com/fustrate/fustrate-rails'
  s.license = 'MIT'

  s.files = ::Dir['{config,lib}/**/*']
  s.executables = []
  s.require_paths = ['lib']

  s.add_development_dependency 'activerecord', '>= 6.0.3', '< 7'
  s.add_development_dependency 'bundler', '> 1.16'
  s.add_development_dependency 'rake', '> 10.0'
  s.add_development_dependency 'rspec', '~> 3.8'
  s.add_development_dependency 'sqlite3'

  s.add_dependency 'activesupport', '>= 6.0.3', '< 7'
  s.add_dependency 'jbuilder', '>= 2.10'
  s.add_dependency 'railties', '>= 6.0.3', '< 7'
  s.add_dependency 'sanitize', '>= 5.1'
end
