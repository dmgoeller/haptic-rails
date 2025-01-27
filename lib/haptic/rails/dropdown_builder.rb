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
          class: ['toggle', @field_options[:class], options[:class]],
          type: 'button'
        )
        @builder.content_tag('button', content, options, &block)
      end

      def popover(content = nil, options = {}, &block)
        content, options = nil, content if content.is_a?(Hash)
        options = options.merge(class: ['popover', options[:class]])

        if block
          @builder.content_tag('div', options) { block.call(PopoverBuilder.new(@builder)) }
        else
          @builder.content_tag('div', content, options)
        end
      end
    end
  end
end
