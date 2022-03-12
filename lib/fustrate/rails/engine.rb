# frozen_string_literal: true

# Copyright (c) 2022 Steven Hoffman
# All rights reserved.

require 'rails/engine'

require 'fustrate/rails/concerns/clean_attributes'
require 'fustrate/rails/concerns/sanitize_html'
require 'fustrate/rails/concerns/model'

require 'fustrate/rails/services/base'
require 'fustrate/rails/services/generate_csv'
require 'fustrate/rails/services/generate_excel'
require 'fustrate/rails/services/log_edit'

module Fustrate
  module Rails
    class Engine < ::Rails::Engine
    end
  end
end
