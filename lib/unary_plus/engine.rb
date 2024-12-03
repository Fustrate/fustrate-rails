# frozen_string_literal: true

# Copyright (c) Steven Hoffman
# All rights reserved.

require 'rails/engine'

# These used to be required automatically, not sure what's going on now.
require_relative '../../config/initializers/jbuilder'
require_relative '../../config/initializers/renderers'
require_relative '../../config/initializers/sanitize'

module UnaryPlus
  class Engine < ::Rails::Engine
  end
end
