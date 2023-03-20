# frozen_string_literal: true

# Copyright (c) Steven Hoffman
# All rights reserved.

::ActionController::Renderers.add :excel do |data, options|
  name = options[:filename] || 'export'

  data_to_send = case data
                 when ::Axlsx::Package then data.to_stream.read
                 when ::StringIO then data.read
                 when ::Array then ::Fustrate::Rails::Services::GenerateExcel.new.call(data, options[:sheet] || name)
                 else
                   data
                 end

  send_data(data_to_send, filename: "#{name}.xlsx", disposition: 'attachment', type: :xlsx)
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
