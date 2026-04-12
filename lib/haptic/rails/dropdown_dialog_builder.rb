# frozen_string_literal: true

module Haptic
  module Rails
    class DropdownDialogBuilder < DropdownBuilder
      # Creates the popover element. If a block is given, it is called with an instance of
      # DialogBuilder as argument.
      def popover(content = nil, **options, &block)
        options = options.merge(class: ['popover', options[:class]])

        if block
          @builder.tag.div(**options) { yield DialogBuilder.new(@builder) }
        else
          @builder.tag.div(content, **options)
        end
      end
    end
  end
end
