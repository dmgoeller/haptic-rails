# frozen_string_literal: true

module Haptic
  module Rails
    class MenuBuilder
      def initialize(builder, defaults = {}) # :nodoc:
        @builder = builder
        @default_options = { is: 'haptic-menu-item' }
        @default_options.merge!(defaults) if defaults.present?
      end

      # Creates a divider.
      def divider
        @builder.content_tag('div', '', class: 'divider')
      end

      # Creates a menu item.
      #
      # ==== Options
      #
      # - <code>:leading_icon</code> - The name of the leading icon.
      #
      # ==== Example
      #
      #   menu.item 'Duplicate', href: '/copy', leading_icon: 'copy'
      #   # =>
      #   # <a is="haptic-menu-item" href="/duplicate">
      #   #   Duplicate
      #   #   <div class="haptic-icon leading-icon">copy</div>
      #   # </a>
      def item(name = nil, options = nil, &block)
        name, options = nil, name if block
        options, content_options = menu_item_options(options)

        @builder.content_tag('a', options) do
          menu_item_content(name, content_options, &block)
        end
      end

      # Creates a menu item pointing to the URL specified by +options+.
      #
      # ==== HTML options
      #
      # - <code>:leading_icon</code> - The name of the leading icon.
      #
      # ==== Example
      #
      #   menu.item_to 'Duplicate', '/copy', leading_icon: 'copy'
      #   # =>
      #   # <a is="haptic-menu-item" href="/duplicate">
      #   #   Duplicate
      #   #   <div class="haptic-icon leading-icon">copy</div>
      #   # </a>
      def item_to(name = nil, options = nil, html_options = nil, &block)
        name, options, html_options = nil, name, options if block
        html_options, content_options = menu_item_options(html_options)

        @builder.link_to(options, html_options) do
          menu_item_content(name, content_options, &block)
        end
      end

      private

      def menu_item_content(name, options, &block)
        (block ? @builder.capture(&block) : name.to_s.html_safe) +
          if (leading_icon = options[:leading_icon])
            @builder.haptic_icon_tag(leading_icon, class: 'leading-icon')
          end
      end

      def menu_item_options(options)
        options = @default_options.merge(options || {})
        content_options = options.extract!(:leading_icon)

        [options, content_options]
      end
    end
  end
end
