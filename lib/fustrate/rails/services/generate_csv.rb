# frozen_string_literal: true

# Copyright (c) 2022 Steven Hoffman
# All rights reserved.

module Fustrate
  module Rails
    module Services
      class GenerateCsv
        def call(data) = data.first.is_a?(::Hash) ? csv_from_hash(data) : csv_from_array(data)

        protected

        def csv_from_hash(data)
          ::CSV.generate do |csv|
            csv << data.first.keys

            data.each do |row|
              csv << (row.values.map { _1&.to_s&.tr("\n", "\v") })
            end
          end
        end

        def csv_from_array(data)
          ::CSV.generate do |csv|
            # It's just an array of arrays; the first row is likely the header
            data.each do |row|
              csv << (Array(row).map { _1&.to_s&.tr("\n", "\v") })
            end
          end
        end
      end
    end
  end
end
