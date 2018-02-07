# frozen_string_literal: true

ActionController::Renderers.add :excel do |data, options|
  name = options[:filename] || 'export'
  sheet = options[:sheet] || name

  headers['Content-Type'] = \
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  headers['Content-Disposition'] = "attachment;filename=#{name}.xlsx"

  render body: Fustrate::Rails::Services::GenerateExcel.new.call(data, sheet)
end

ActionController::Renderers.add :csv do |data, options|
  name = options[:filename] || 'export'

  headers['Content-Type'] = 'text/csv'
  headers['Content-Disposition'] = "attachment;filename=#{name}.csv"

  render body: Fustrate::Rails::Services::GenerateCsv.new.call(data)
end
