# frozen_string_literal: true

module Haptic
  module Rails
    class DropdownBuilder
      def initialize(builder)
        @builder = builder
      end

      def toggle(content = nil, options = {}, &block)
        options = options.merge(
          type: 'button',
          class: [options[:class], 'toggle', 'haptic-field']
        )
        @builder.content_tag('button', content, options, &block)
      end

      def popover(content = nil, options = {}, &block)
        options = options.merge(class: [options[:class], 'popover'])

        @builder.content_tag('div', content, options, &block)
      end
    end
  end
end
