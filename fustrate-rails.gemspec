$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'fustrate/rails/version'

Gem::Specification.new do |s|
  s.name = 'fustrate-rails'
  s.version = Fustrate::Rails::VERSION
  s.authors = ['Steven Hoffman']
  s.homepage = 'https://github.com/fustrate/fustrate-rails'
  s.summary = <<-SUMMARY
    JS/CSS framework customized to my preferences, long ago based on
    Foundation 5. Needs an actual name.
  SUMMARY

  s.license = 'MIT'
  s.description = <<-DESCRIPTION
    A coffeescript/sass library that encapsulates common code that I use on
    multiple projects. It was originally based on Foundation 5, but nearly
    everything has been changed.
  DESCRIPTION

  s.files = Dir['{lib,vendor}/**/*']
  s.executables = []
  s.require_paths = ['lib']

  s.add_runtime_dependency 'coffee-script', '>= 2.4'
  s.add_runtime_dependency 'sass', '>= 3.4'
  s.add_runtime_dependency 'railties', '>= 4', '< 5.3'

  # CSS Libraries
  s.add_runtime_dependency 'bourbon'

  # JavaScript Libraries
  s.add_runtime_dependency 'js-routes'
  s.add_runtime_dependency 'modernizr-rails'
  s.add_runtime_dependency 'momentjs-rails'
end
