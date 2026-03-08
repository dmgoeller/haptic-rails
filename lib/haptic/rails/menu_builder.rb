# frozen_string_literal: true

module Haptic
  module Rails
    class MenuBuilder
      def initialize(builder, defaults = {}) # :nodoc:
        @builder = builder
        @default_options = { is: 'haptic-menu-item' }
        @default_options.merge!(defaults) if defaults.present?
      end

      def divider
        @builder.content_tag('div', '', class: 'divider')
      end

      def item(name = nil, options = nil, &block)
        if block_given?
          name = menu_item_options(name)
        else
          options = menu_item_options(options)
        end
        @builder.content_tag('a', name, options, &block)
      end

      def item_to(name = nil, options = nil, html_options = nil, &block)
        if block_given?
          options = menu_item_options(options)
        else
          html_options = menu_item_options(html_options)
        end
        @builder.link_to(name, options, html_options, &block)
      end

      private

      def menu_item_options(options)
        @default_options.merge(options || {})
      end
    end
  end
end
