# frozen_string_literal: true

# Copyright (c) 2022 Steven Hoffman
# All rights reserved.

module Fustrate
  module Rails
    module Concerns
      module CleanAttributes
        extend ::ActiveSupport::Concern

        STRING_TYPES = %i[string text citext].freeze

        # Collapse multiple spaces, remove leading/trailing whitespace, and remove carriage returns
        def self.strip(text)
          return if text.blank?

          return text.map { strip(_1) } if text.is_a?(::Array)

          text.strip.gsub(/ {2,}/, ' ').gsub(/^[ \t]+|[ \t]+$/, '').gsub(/\r\n?/, "\n").gsub(/\n{3,}/, "\n\n")
        end

        included do |base|
          # There's no reason to clean polymorphic type columns
          polymorphic_type_columns = base.reflect_on_all_associations
            .select { _1.options[:polymorphic] }
            .map { "#{_1.name}_type" }

          string_columns = base.columns
            .select { self::STRING_TYPES.include?(_1.sql_type_metadata.type) }
            .reject { polymorphic_type_columns.include?(_1.name) }
            .map(&:name)

          before_validation do
            string_columns.each do |attribute|
              next unless self[attribute]

              self[attribute] = ::Fustrate::Rails::Concerns::CleanAttributes.strip self[attribute]
            end
          end
        end
      end
    end
  end
end
