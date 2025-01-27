# frozen_string_literal: true

module Haptic
  module Rails
    class FieldOptions
      delegate_missing_to :options

      %i[merge merge! reverse_merge reverse_merge!].each do |name|
        define_method(name) do |options = {}|
          self.options.public_send(name, options.symbolize_keys)
        end
      end

      def initialize(options = {})
        @stacked_options = [options]
      end

      def options
        @stacked_options.last
      end

      def pop
        @stacked_options.pop
      end

      def push(options = {})
        @stacked_options.push(options.merge(self.options))
        self
      end
    end
  end
end
