# frozen_string_literal: true

# Copyright (c) Steven Hoffman
# All rights reserved.

::ActionController::Renderers.add :excel do |data, options|
  name = options[:filename] || 'export'

  render_options = { filename: "#{name}.xlsx", disposition: 'attachment', type: :xlsx }

  case data
  when ::Axlsx::Package
    send_data(data.to_stream.read, **render_options)
  when ::Array
    send_data(::Fustrate::Rails::Services::GenerateExcel.new.call(data, options[:sheet] || name), **render_options)
  when ::Pathname
    render_options[:filename] = data.basename.to_s if render_options[:filename] == 'export'

    send_file(data, **render_options)
  else
    send_data(data, **render_options)
  end
end

::ActionController::Renderers.add :csv do |data, options|
  name = options[:filename] || 'export'

  send_data(
    ::Fustrate::Rails::Services::GenerateCsv.new.call(data),
    filename: "#{name}.csv",
    disposition: 'attachment',
    type: :csv
  )
end

::ActionController::Renderers.add :zip do |path, options|
  send_file path, type: :zip, filename: "#{options[:filename]}.zip"
end
