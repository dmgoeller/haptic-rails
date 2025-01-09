# frozen_string_literal: true

module Haptic
  module Rails
    class DropdownBuilder
      def initialize(builder, field_options)
        @builder = builder
        @field_options = field_options
      end

      def toggle(content = nil, options = {}, &block)
        content, options = nil, content if content.is_a?(Hash)

        options = options.merge(
          class: [options[:class], @field_options[:class], 'toggle'].flatten,
          type: 'button'
        )
        @builder.content_tag('button', content, options, &block)
      end

      def popover(content = nil, options = {}, &block)
        content, options = nil, content if content.is_a?(Hash)
        options = options.merge(class: [options[:class], 'popover'])

        @builder.content_tag('div', content, options, &block)
      end
    end
  end
end