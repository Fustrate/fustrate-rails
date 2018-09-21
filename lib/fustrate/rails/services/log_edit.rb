# frozen_string_literal: true

module Fustrate
  module Rails
    module Services
      module LogEdit
        IGNORE_COLUMNS = %i[updated_at].freeze
        DATE_FIELDS = [].freeze
        DATETIME_FIELDS = [].freeze
        BOOLEAN_FIELDS = [].freeze

        def call(subject, force: false, note: nil)
          # Make sure any before_validation callbacks are run
          subject.validate

          @subject = subject
          @force = force
          @note = note
          @data = subject.changes.except(*self.class::IGNORE_COLUMNS)

          process_timestamps
          process_booleans

          process

          record_edit
        end

        protected

        def record_edit
          # Get rid of changes from nil to '' and whatnot
          @data.delete_if { |_, values| values.all?(&:blank?) || values.uniq.one? }

          return if @data.empty? && !@force

          log_edit_on.events.new(
            type: 'Edited',
            user: Current.user,
            data: @data,
            note: @note
          )
        end
        
        # Allow edit data to be recorded on a model that isn't @subject
        def log_edit_on
          @subject
        end

        def process; end

        # Format fields that are timestamps
        def process_timestamps
          self.class::DATE_FIELDS
            .select { |key| @data[key] }
            .each do |key|
              @data[key] = format_timestamps(@data[key], time: false)
            end

          self.class::DATETIME_FIELDS
            .select { |key| @data[key] }
            .each do |key|
              @data[key] = format_timestamps(@data[key], time: true)
            end
        end

        def process_booleans
          self.class::BOOLEAN_FIELDS
            .select { |key| @data[key] }
            .each { |key| @data[key] = @data[key][1] ? %w[No Yes] : %w[Yes No] }
        end

        def format_timestamps(datetimes, time: true)
          datetimes.map do |timestamp|
            next unless timestamp

            timestamp.strftime(time ? '%-m/%-d/%y %-I:%M %p' : '%-m/%-d/%y')
          end
        end

        def find_polymorphic_name(type, id)
          return unless type && id

          Object.const_get(type).find(id).to_s
        end
      end
    end
  end
end
