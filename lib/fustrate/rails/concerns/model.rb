# frozen_string_literal: true

# Copyright (c) 2021 Steven Hoffman
# All rights reserved.

module Fustrate
  module Rails
    module Concerns
      module Model
        extend ::ActiveSupport::Concern

        module ClassMethods
          # Allow models to define a more reasonable name, usually used to remove a module/namespace.
          def human_name(new_name = nil)
            @_human_name = new_name.to_s if new_name

            @_human_name || to_s.underscore
          end
        end

        included do
          self.abstract_class = true
          self.inheritance_column = :_disabled

          # Assign strong parameters based on the class name - just a convenience method for services.
          def assign_params(permitted_params, key: nil)
            assign_attributes ::Current.params.require(
              key || ::ActiveModel::Naming.param_key(self.class)
            ).permit(permitted_params)
          end

          # Define a different Editable record to log edits on
          def log_edits_on
            self
          end
        end
      end
    end
  end
end
