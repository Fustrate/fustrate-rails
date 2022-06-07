# frozen_string_literal: true

# Copyright (c) 2022 Steven Hoffman
# All rights reserved.

module Fustrate
  module Rails
    module SpecHelper
      include ::ActiveSupport::Testing::TimeHelpers

      def accept(mime)
        request.accept = mime['/'] ? mime : ::Mime::Type.lookup_by_extension(mime)
      end

      # Just helps to shorten some absurdly long error message keys
      def error_t(model, attribute, key)
        key = "attributes.#{attribute}.#{key}" if attribute

        ::I18n.t "activerecord.errors.models.#{model.model_name.i18n_key}.#{key}"
      end

      def double_list(name, count, **stubs)
        ::Array.new(count) { instance_double(name, stubs) }
      end

      def data_from_file(name, **interpolations)
        ::Dir.glob(::Rails.root.join('spec', 'data', "#{name}.*")) do |filename|
          case ::File.extname filename
          when '.yml', '.yaml'
            return yaml_data_from_file(filename, **interpolations)
          else
            raise ::ArgumentError, "Could not parse unknown file type #{::File.extname filename}"
          end
        end
      end

      def yaml_data_from_file(filename, **interpolations)
        ::YAML.safe_load read_with_interpolations(filename, interpolations), aliases: true
      end

      def image_file(filename, type = 'image/jpeg')
        ::Rack::Test::UploadedFile.new ::Rails.root.join('spec', 'files', filename), type
      end

      def pdf_file(filename)
        ::Rack::Test::UploadedFile.new ::Rails.root.join('spec', 'files', filename), 'application/pdf'
      end

      # A few cron scripts use `puts` and clog up STDOUT.
      def stfu
        orig_stdout = $stdout.clone
        $stdout.reopen ::File.new('/dev/null', 'w')
        yield
      rescue ::StandardError => e
        $stdout.reopen orig_stdout
        raise e
      ensure
        $stdout.reopen orig_stdout
      end

      protected

      def read_with_interpolations(filename, interpolations) = ::File.read(filename) % interpolations
    end
  end
end
