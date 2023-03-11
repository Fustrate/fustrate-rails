# frozen_string_literal: true

# Copyright (c) Steven Hoffman
# All rights reserved.

::ActionController::Renderers.add :excel do |data, options|
  name = options[:filename] || 'export'
  sheet = options[:sheet] || name

  send_data(
    ::Fustrate::Rails::Services::GenerateExcel.new.call(data, sheet),
    filename: "#{name}.xlsx",
    disposition: 'attachment',
    type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  )
end

::ActionController::Renderers.add :csv do |data, options|
  name = options[:filename] || 'export'

  send_data(
    ::Fustrate::Rails::Services::GenerateCsv.new.call(data),
    filename: "#{name}.csv",
    disposition: 'attachment',
    type: 'text/csv'
  )
end
