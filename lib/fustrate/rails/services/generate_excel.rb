# frozen_string_literal: true

# Copyright (c) 2022 Steven Hoffman
# All rights reserved.

module Fustrate
  module Rails
    module Services
      class GenerateExcel
        def call(data, name = 'Sheet 1')
          ::Axlsx::Package.new do |package|
            package.use_shared_strings = true

            @wrap = package.workbook.styles.add_style(alignment: { wrap_text: true })

            package.workbook.add_worksheet(name:) { add_data_to_sheet(data, _1) }

            return package.to_stream.read
          end
        end

        protected

        def add_data_to_sheet(data, sheet)
          sheet.add_row data.first.keys if data.any?

          data.each { sheet.add_row _1.values, style: @wrap }
        end
      end
    end
  end
end
