# frozen_string_literal: true

module Haptic
  module Rails
    class DropdownDialogBuilder < DropdownBuilder
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
