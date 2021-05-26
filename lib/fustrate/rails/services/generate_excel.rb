# frozen_string_literal: true

# Copyright (c) 2021 Steven Hoffman
# All rights reserved.

module Fustrate
  module Rails
    module Services
      class GenerateExcel
        def call(data, sheet_name = 'Sheet 1')
          ::Axlsx::Package.new do |package|
            package.use_shared_strings = true

            @wrap = package.workbook.styles.add_style(alignment: { wrap_text: true })

            package.workbook.add_worksheet(name: sheet_name) do |sheet|
              add_data_to_sheet(data, sheet)
            end

            return package.to_stream.read
          end
        end

        protected

        def add_data_to_sheet(data, sheet)
          sheet.add_row data.first.keys if data.any?

          data.each { |row| sheet.add_row row.values, style: @wrap }
        end
      end
    end
  end
end
