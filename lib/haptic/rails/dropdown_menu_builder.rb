# frozen_string_literal: true

module Haptic
  module Rails
    class DropdownMenuBuilder < DropdownBuilder
      def initialize(builder) # :nodoc:
        super(builder, is: 'haptic-button')
      end

      def menu(options = {})
        options = options.merge(class: ['popover', options[:class]].compact.flatten)
        defaults = options.delete(:defaults)

        @builder.haptic_menu_tag(options) do
          yield MenuBuilder.new(@builder, defaults) if block_given?
        end
      end
    end
  end
end
