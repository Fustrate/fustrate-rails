# frozen_string_literal: true

# Copyright (c) 2022 Steven Hoffman
# All rights reserved.

module Fustrate
  module Rails
    module Services
      module LogEdit
        IGNORE_COLUMNS = %w[id created_at updated_at].freeze
        RENAME_COLUMNS = {}.freeze

        def call(subject, force: false, note: nil)
          # Make sure any before_validation callbacks are run
          subject.validate

          @subject = subject
          @force = force
          @note = note
          @data = subject.changes.except(*self.class::IGNORE_COLUMNS)

          process_changes

          self.class::RENAME_COLUMNS.each do |from, to|
            @data[to] = @data.delete from if @data[from]
          end

          record_edit
        end

        protected

        def record_edit
          # Get rid of changes from nil to '' and whatnot
          @data.delete_if { |_, values| values.all?(&:blank?) || values[0] == values[1] }

          return if @data.empty? && !@force

          log_edit_on_relation.new(
            type: 'Edited',
            user: ::Current.user,
            data: { changes: @data, raw_changes: raw_changes }.merge(additional_data),
            note: @note
          )
        end

        # Allow edit data to be recorded on a model that isn't @subject
        def log_edit_on
          @subject
        end

        def log_edit_on_relation
          log_edit_on.events
        end

        def additional_data
          {}
        end

        def raw_changes
          @subject.changes
        end

        def process_changes
          process_datetime_columns
          process_date_columns
          process_boolean_columns
          process_relations
        end

        def process_datetime_columns
          columns_of_type(:date).each do |col|
            @data[col] = format_timestamps(@data[col], time: false)
          end
        end

        def process_date_columns
          columns_of_type(:datetime).each do |col|
            @data[col] = format_timestamps(@data[col], time: true)
          end
        end

        def process_boolean_columns
          columns_of_type(:boolean).each do |col|
            @data[col] = @data[col][1] ? %w[No Yes] : %w[Yes No]
          end
        end

        def columns_of_type(type)
          Array(columns[type]).select { |col| @data[col] }
        end

        def process_relations
          @subject.class.reflect_on_all_associations.each do |relation|
            if relation.options[:polymorphic]
              process_polymorphic_relation(relation.name)
            elsif relation.is_a?(::ActiveRecord::Reflection::BelongsToReflection)
              process_belongs_to_relation(relation.name)
            end
          end
        end

        def process_polymorphic_relation(name)
          return unless @data["#{name}_id"] || @data["#{name}_type"]

          @data.delete("#{name}_id")
          @data.delete("#{name}_type")

          # The type, and in rare cases the ID, may not have actually changed
          old_id = @subject.__send__("#{name}_id_in_database")
          old_type = @subject.__send__("#{name}_type_in_database").presence

          @data[name] = [
            (::Object.const_get(old_type).find(old_id)&.to_s if old_type),
            @subject.__send__(name)&.to_s
          ]
        end

        def columns
          # .reject { |col| col.name.match?(/_(?:type|id)\z/) }
          @columns ||= @subject.class.columns
            .reject { |col| self.class::IGNORE_COLUMNS.include? col.name }
            .group_by { |column| column.sql_type_metadata.type }
            .transform_values { |cols| cols.map { |col| col.name.to_sym } }
        end

        def process_belongs_to_relation(name)
          return unless @data["#{name}_id"]

          new_value = @subject.__send__(name)

          old_value_id = @data.delete("#{name}_id")[0]

          # If we're removing the value, new_value.class will be nil, so we need to use reflection.
          @data[name] = [
            (@subject.class.reflect_on_association(name).klass.find(old_value_id)&.to_s if old_value_id),
            new_value&.to_s
          ]
        end

        def format_timestamps(datetimes, time: true)
          datetimes.map { |timestamp| timestamp&.strftime(time ? '%-m/%-d/%y %-I:%M %p' : '%-m/%-d/%y') }
        end
      end
    end
  end
end
