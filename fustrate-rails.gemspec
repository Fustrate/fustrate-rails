# frozen_string_literal: true

# Copyright (c) Steven Hoffman
# All rights reserved.

$LOAD_PATH.push ::File.expand_path('lib', __dir__)
require 'fustrate/rails/version'

::Gem::Specification.new do |spec|
  spec.name = 'fustrate-rails'
  spec.version = ::Fustrate::Rails::VERSION
  spec.authors = ['Steven Hoffman']
  spec.required_ruby_version = '>= 3.3.0'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.summary = 'A few useful services and initializers.'
  spec.homepage = 'https://github.com/fustrate/fustrate-rails'
  spec.license = 'MIT'

  spec.files = ::Dir['{config,lib}/**/*']
  spec.executables = []
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 7.2'
  spec.add_dependency 'jbuilder', '~> 2.11'
  spec.add_dependency 'railties', '>= 7.2'
  spec.add_dependency 'sanitize', '~> 6.1'
end
