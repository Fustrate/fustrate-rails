# frozen_string_literal: true

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

  s.add_runtime_dependency 'jbuilder', '>= 2.7'
  s.add_runtime_dependency 'railties', '>= 5.2.0.rc1', '< 6.1'
end
