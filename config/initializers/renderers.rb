# frozen_string_literal: true

# Copyright (c) Steven Hoffman
# All rights reserved.

require 'action_controller/metal/renderers'

::ActionController::Renderers.add :excel do |data, options|
  name = options[:filename] || 'export'

  xlsx_options = { filename: "#{name}.xlsx", disposition: 'attachment', type: :xlsx }

  case data
  when ::Axlsx::Package
    send_data(data.to_stream.read, **xlsx_options)
  when ::Array
    send_data(::UnaryPlus::Services::GenerateExcel.new.call(data, options[:sheet] || name), **xlsx_options)
  when ::Pathname
    xlsx_options[:filename] = data.basename.to_s if xlsx_options[:filename] == 'export'

    send_file(data, **xlsx_options)
  else
    send_data(data, **xlsx_options)
  end
end

::ActionController::Renderers.add :csv do |data, options|
  name = options[:filename] || 'export'

  csv_options = { filename: "#{name}.csv", disposition: 'attachment', type: :csv }

  case data
  when ::Array, ::Hash
    send_data(::UnaryPlus::Services::GenerateCsv.new.call(data), **csv_options)
  else
    send_data(data, **csv_options)
  end
end

::ActionController::Renderers.add :zip do |path, options|
  send_file path, type: :zip, filename: "#{options[:filename]}.zip"
end
