# frozen_string_literal: true

# Copyright (c) 2021 Steven Hoffman
# All rights reserved.

module Fustrate
  module Rails
    module Services
      class GenerateCsv
        def call(data)
          return csv_from_hash(data) if data.first.is_a? ::Hash

          csv_from_array(data)
        end

        protected

        def csv_from_hash(data)
          ::CSV.generate do |csv|
            csv << data.first.keys

            data.each do |row|
              csv << (row.values.map { |val| val&.to_s&.tr("\n", "\v") })
            end
          end
        end

        def csv_from_array(data)
          ::CSV.generate do |csv|
            # It's just an array of arrays; the first row is likely the header
            data.each do |row|
              csv << (Array(row).map { |val| val&.to_s&.tr("\n", "\v") })
            end
          end
        end
      end
    end
  end
end
