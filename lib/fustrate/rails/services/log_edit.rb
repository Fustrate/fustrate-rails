# frozen_string_literal: true

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

          RENAME_COLUMNS.each do |from, to|
            @data[to] = @data.delete from if @data[from]
          end

          record_edit
        end

        protected

        def record_edit
          # Get rid of changes from nil to '' and whatnot
          @data.delete_if do |_, values|
            values.all?(&:blank?) || values[0] == values[1]
          end

          return if @data.empty? && !@force

          log_edit_on.events.new(
            type: 'Edited',
            user: Current.user,
            data: { changes: @data, raw_changes: @subject.changes },
            note: @note
          )
        end

        # Allow edit data to be recorded on a model that isn't @subject
        def log_edit_on
          @subject
        end

        def process_changes
          process_datetime_columns
          process_date_columns
          process_boolean_columns
          process_relations
        end

        def process_datetime_columns
          Array(columns[:date]).select { |col| @data[col] }.each do |col|
            @data[col] = format_timestamps(@data[col], time: false)
          end
        end

        def process_date_columns
          Array(columns[:datetime]).select { |col| @data[col] }.each do |col|
            @data[col] = format_timestamps(@data[col], time: true)
          end
        end

        def process_boolean_columns
          Array(columns[:boolean]).select { |col| @data[col] }.each do |col|
            @data[col] = @data[col][1] ? %w[No Yes] : %w[Yes No]
          end
        end

        def process_relations
          @subject.class.reflect_on_all_associations.each do |relation|
            if relation.options[:polymorphic]
              process_polymorphic_relation(relation.name)
            elsif relation.is_a?(ActiveRecord::Reflection::BelongsToReflection)
              process_belongs_to_relation(relation.name)
            end
          end
        end

        def process_polymorphic_relation(name)
          return unless @data["#{name}_id"] || @data["#{name}_type"]

          @data.delete("#{name}_id")
          @data.delete("#{name}_type")

          # The type, and in rare cases the ID, may not have actually changed
          old_id = @subject.send("#{name}_id_in_database")
          old_type = @subject.send("#{name}_type_in_database")

          @data[relation.name] = [
            Object.const_get(old_type).find(old_id)&.to_s,
            @subject.send(name)&.to_s
          ]
        end

        def columns
          # .reject { |col| col.name.match?(/_(?:type|id)\z/) }
          @columns ||= @subject.class.columns
            .reject { |col| IGNORE_COLUMNS.include? col.name }
            .group_by { |column| column.sql_type_metadata.type }
            .map { |type, cols| [type, cols.map { |col| col.name.to_sym }] }
            .to_h
        end

        def process_belongs_to_relation(name)
          return unless @data["#{name}_id"]

          new_value = @subject.send(name)

          change = @data.delete "#{name}_id"

          @data[name] = [
            (new_value.class.find(change[0])&.to_s if change[0]),
            new_value&.to_s
          ]
        end

        def format_timestamps(datetimes, time: true)
          datetimes.map do |timestamp|
            next unless timestamp

            timestamp.strftime(time ? '%-m/%-d/%y %-I:%M %p' : '%-m/%-d/%y')
          end
        end
      end
    end
  end
end
