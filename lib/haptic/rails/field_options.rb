# frozen_string_literal: true

module Haptic
  module Rails
    class FieldOptions
      delegate_missing_to :options

      def initialize
        @stacked_options = [{}]
      end

      def options
        @stacked_options.last
      end

      def pop
        @stacked_options.pop
      end

      def push(options = {})
        @stacked_options.push(options.merge(@stacked_options.last))
        self
      end
    end
  end
end
