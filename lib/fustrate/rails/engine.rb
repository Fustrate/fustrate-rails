# frozen_string_literal: true

require 'rails/engine'

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
