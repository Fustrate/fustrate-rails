# frozen_string_literal: true

# Copyright (c) 2020 Steven Hoffman
# All rights reserved.

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'fustrate/rails/version'

Gem::Specification.new do |s|
  s.name = 'fustrate-rails'
  s.version = Fustrate::Rails::VERSION
  s.authors = ['Steven Hoffman']
  s.homepage = 'https://github.com/fustrate/fustrate-rails'
  s.summary = <<-SUMMARY
    A few useful services and initializers.
  SUMMARY

  s.license = 'MIT'
  s.description = <<-DESCRIPTION
    A few useful services and initializers.
  DESCRIPTION

  s.files = Dir['{config,lib}/**/*']
  s.executables = []
  s.require_paths = ['lib']

  s.add_runtime_dependency 'jbuilder', '>= 2.10'
  s.add_runtime_dependency 'railties', '>= 6.0.3', '< 7'
  s.add_runtime_dependency 'sanitize', '>= 5.1'
end
