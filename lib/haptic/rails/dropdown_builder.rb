# frozen_string_literal: true

module Haptic
  module Rails
    class DropdownBuilder
      def initialize(builder, toggle_options = {}) # :nodoc:
        @builder = builder
        @toggle_options = toggle_options
      end

      def toggle(content = nil, options = {}, &block)
        content, options = nil, content if content.is_a?(Hash)

        options = options.merge(@toggle_options.except(:class))
        options[:class] = ['toggle', @toggle_options[:class], options[:class]]
        options[:type] = 'button'

        @builder.content_tag('button', content, options, &block)
      end
    end
  end
end
