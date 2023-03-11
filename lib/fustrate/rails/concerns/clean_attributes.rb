# frozen_string_literal: true

# Copyright (c) Steven Hoffman
# All rights reserved.

module Fustrate
  module Rails
    module Concerns
      module CleanAttributes
        extend ::ActiveSupport::Concern

        STRING_TYPES = %i[string text citext].freeze

        # Collapse multiple spaces, remove leading/trailing whitespace, and remove carriage returns
        def self.strip(text)
          return text.map { strip(_1) } if text.is_a?(::Array)

          return if text.blank?

          text.strip.gsub(/ {2,}/, ' ').gsub(/^[ \t]+|[ \t]+$/, '').gsub(/\r\n?/, "\n").gsub(/\n{3,}/, "\n\n")
        end

        def self.string_columns(klass)
          # There's no reason to clean polymorphic type columns
          polymorphic_type_columns = klass.reflect_on_all_associations
            .select { _1.options[:polymorphic] }
            .map { "#{_1.name}_type" }

          klass.columns
            .select { self::STRING_TYPES.include?(_1.sql_type_metadata.type) }
            .reject { polymorphic_type_columns.include?(_1.name) }
            .map(&:name)
        end

        def self.clean_record(record)
          string_columns(record.class).each do |attribute|
            next unless record[attribute]

            record[attribute] = strip record[attribute]
          end
        end

        included do
          before_validation { ::Fustrate::Rails::Concerns::CleanAttributes.clean_record(self) }
        end
      end
    end
  end
end
