# frozen_string_literal: true

# Copyright (c) Steven Hoffman
# All rights reserved.

module UnaryPlus
  class Railtie < Rails::Railtie
    initializer 'unary_plus.configure_rails_initialization' do
      Dir[File.expand_path("#{__dir__}/../../config/initializers/*")].each do |initializer|
        require initializer
      end
    end
  end
end
