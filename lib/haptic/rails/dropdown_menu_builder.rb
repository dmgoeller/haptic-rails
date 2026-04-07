# frozen_string_literal: true

module Haptic
  module Rails
    class DropdownMenuBuilder < DropdownBuilder
      def initialize(builder) # :nodoc:
        super(builder, is: 'haptic-button')
      end

      # :call-seq: menu(**options, &block)
      #
      # Creates the menu to be poped up. Passes an instance of MenuBuilder to the block.
      #
      # ==== Options
      #
      # - <code>:defaults</code> - The default options to be applied to all menu items.
      #
      # ==== Example
      #
      #   menu(defaults: { rel: 'next' }) do |menu|
      #     menu.item('Duplicate', href: '/duplicate')
      #   end
      #   # =>
      #   # <haptic-menu class="popover">
      #   #   <a is="haptic-menu-item" href="/duplicate" rel="next">Duplicate</a>
      #   # </haptic-menu>
      def menu(**options)
        options = options.merge(class: ['popover', options[:class]])
        defaults = options.delete(:defaults) || {}

        @builder.tag.haptic_menu(**options) do
          yield MenuBuilder.new(@builder, **defaults) if block_given?
        end
      end
    end
  end
end
