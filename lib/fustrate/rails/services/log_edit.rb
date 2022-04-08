# frozen_string_literal: true

# Copyright (c) 2022 Steven Hoffman
# All rights reserved.

module Fustrate
  module Rails
    module Services
      module LogEdit
        IGNORE_COLUMNS = %w[id created_at updated_at].freeze
        RENAME_COLUMNS = {}.freeze

        attr_reader :subject, :force, :note, :user

        def call(subject, force: false, note: nil, user: nil)
          # Make sure any before_validation callbacks are run
          subject.validate

          @subject = subject
          @force = force
          @note = note
          @user = user || ::Current.user

          process_changes

          self.class::RENAME_COLUMNS.each do |from, to|
            changes[to] = changes.delete(from) if changes[from]
          end

          record_edit
        end

        protected

        def changes
          @changes ||= subject.changes.except(*self.class::IGNORE_COLUMNS)
        end

        def record_edit
          # Get rid of changes from nil to '' and whatnot
          changes.delete_if { |_, values| values.all?(&:blank?) || values[0] == values[1] }

          return if changes.empty? && !force

          log_edit_on_relation.new(type: 'Edited', user:, note:, data: edit_data)
        end

        # Allow edits to be recorded on a model that isn't `subject`
        def log_edit_on = subject

        def log_edit_on_relation = log_edit_on.events

        def edit_data = { changes:, raw_changes:, **additional_data }

        def additional_data = {}

        def raw_changes = subject.changes

        def process_changes
          process_datetime_columns
          process_date_columns
          process_boolean_columns
          process_relations
        end

        def process_datetime_columns
          columns_of_type(:date).each do |col|
            changes[col] = format_timestamps(changes[col], time: false)
          end
        end

        def process_date_columns
          columns_of_type(:datetime).each do |col|
            changes[col] = format_timestamps(changes[col], time: true)
          end
        end

        def process_boolean_columns
          columns_of_type(:boolean).each do |col|
            changes[col] = changes[col][1] ? %w[No Yes] : %w[Yes No]
          end
        end

        def columns_of_type(type) = Array(columns[type]).select { changes[_1] }

        def process_relations
          subject.class.reflect_on_all_associations.each do |relation|
            if relation.options[:polymorphic]
              process_polymorphic_relation(relation.name)
            elsif relation.is_a?(::ActiveRecord::Reflection::BelongsToReflection)
              process_belongs_to_relation(relation.name)
            end
          end
        end

        def process_polymorphic_relation(name)
          return unless changes["#{name}_id"] || changes["#{name}_type"]

          changes.delete("#{name}_id")
          changes.delete("#{name}_type")

          changes[name] = [find_old_polymorphic_record(name), subject.__send__(name)&.to_s]
        end

        def find_old_polymorphic_record(name)
          # The type, and in rare cases the ID, may not have actually changed
          old_id = subject.__send__("#{name}_id_in_database")
          old_type = subject.__send__("#{name}_type_in_database").presence

          ::Object.const_get(old_type).find(old_id)&.to_s if old_type
        end

        def columns
          # .reject { _1.name.match?(/_(?:type|id)\z/) }
          @columns ||= subject.class.columns
            .reject { self.class::IGNORE_COLUMNS.include? _1.name }
            .group_by { _1.sql_type_metadata.type }
            .transform_values { |cols| cols.map { _1.name.to_sym } }
        end

        def process_belongs_to_relation(name)
          return unless changes["#{name}_id"]

          new_value = subject.__send__(name)

          old_value_id = changes.delete("#{name}_id")[0]

          # If we're removing the value, new_value.class will be nil, so we need to use reflection.
          changes[name] = [
            (subject.class.reflect_on_association(name).klass.find(old_value_id)&.to_s if old_value_id),
            new_value&.to_s
          ]
        end

        def format_timestamps(datetimes, time: true)
          datetimes.map { _1&.strftime(time ? '%-m/%-d/%y %-I:%M %p' : '%-m/%-d/%y') }
        end
      end
    end
  end
end
