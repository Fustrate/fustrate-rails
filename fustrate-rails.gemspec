# frozen_string_literal: true

# Copyright (c) Steven Hoffman
# All rights reserved.

$LOAD_PATH.push ::File.expand_path('lib', __dir__)
require 'fustrate/rails/version'

::Gem::Specification.new do |s|
  s.name = 'fustrate-rails'
  s.version = ::Fustrate::Rails::VERSION
  s.authors = ['Steven Hoffman']
  s.required_ruby_version = '>= 3.2.0'
  s.metadata['rubygems_mfa_required'] = 'true'

  s.summary = 'A few useful services and initializers.'
  s.homepage = 'https://github.com/fustrate/fustrate-rails'
  s.license = 'MIT'

  s.files = ::Dir['{config,lib}/**/*']
  s.executables = []
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '>= 6.0.3', '< 8'
  s.add_dependency 'jbuilder', '~> 2.11'
  s.add_dependency 'railties', '>= 6.0.3', '< 8'
  s.add_dependency 'sanitize', '~> 6.0'
end
