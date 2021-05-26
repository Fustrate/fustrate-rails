# frozen_string_literal: true

# Copyright (c) 2021 Steven Hoffman
# All rights reserved.

module Fustrate
  module Rails
    module Concerns
      module SanitizeHtml
        extend ::ActiveSupport::Concern

        def self.sanitize(html, config)
          # Remove non-breaking & ideographic spaces before sanitizing, and un-fancy quotes.
          normalized = html
            .tr('‘’“”', %q(''""))
            .gsub(/(?:[\u00A0\u3000]|&nbsp;) ?/, ' ')

          ::Sanitize.fragment(normalized, config).strip
        end

        module ClassMethods
          def sanitize_html(*attributes, config)
            before_validation do
              attributes.flatten.each do |attribute|
                next unless self[attribute]

                self[attribute] = ::Fustrate::Rails::Concerns::SanitizeHtml.sanitize(self[attribute], config)
              end
            end
          end
        end
      end
    end
  end
end
