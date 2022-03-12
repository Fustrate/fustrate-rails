# frozen_string_literal: true

# Copyright (c) 2022 Steven Hoffman
# All rights reserved.

module Fustrate
  module Rails
    module Services
      class Base
        # Lets us use `t` and `l` helpers.
        include ::ActionView::Helpers::TranslationHelper

        protected

        def service(service_class)
          service_class.new
        end

        def authorize(action, resource)
          ::Authority.enforce(action, resource, ::Current.user)
        end

        def transaction(&block)
          ::ActiveRecord::Base.transaction(&block)
        end

        class LoadPage < self
          DEFAULT_ORDER = nil
          DEFAULT_INCLUDES = nil
          RESULTS_PER_PAGE = 25

          def call(page: nil, includes: nil, scope: nil, order: nil)
            (scope || default_scope)
              .reorder(order || default_order)
              .paginate(page: page || params[:page], per_page: self.class::RESULTS_PER_PAGE)
              .includes(includes || self.class::DEFAULT_INCLUDES)
          end

          protected

          def default_scope
            raise ::NotImplementedError, '#default_scope not defined'
          end

          def default_order
            return self.class::DEFAULT_ORDER.call if self.class::DEFAULT_ORDER.is_a? ::Proc

            self.class::DEFAULT_ORDER
          end
        end
      end
    end
  end
end
