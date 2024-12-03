# frozen_string_literal: true

# Copyright (c) Steven Hoffman
# All rights reserved.

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

module UnaryPlus
end

require 'unary_plus/railtie' if defined?(Rails::Railtie)
