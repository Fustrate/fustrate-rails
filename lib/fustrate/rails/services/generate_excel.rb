# frozen_string_literal: true

module Fustrate
  module Rails
    module Services
      class GenerateExcel
        def call(data, sheet_name = 'Sheet 1')
          Axlsx::Package.new do |package|
            package.use_shared_strings = true

            wrap = package.workbook.styles
              .add_style(alignment: { wrap_text: true })

            package.workbook.add_worksheet(name: sheet_name) do |sheet|
              sheet.add_row data.first.keys

              data.each { |row| sheet.add_row row.values, style: wrap }
            end

            return package.to_stream.read
          end
        end
      end
    end
  end
end
