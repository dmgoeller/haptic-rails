# frozen_string_literal: true

module Haptic
  module Rails
    class MenuBuilder
      def initialize(builder, **defaults) # :nodoc:
        @builder = builder
        @defaults = { is: 'haptic-menu-item' }
        @defaults.merge!(defaults) if defaults.present?
      end

      # Adds a divider.
      def divider
        @builder.tag.div(class: 'divider')
      end

      # Adds a menu item.
      #
      # ==== Options
      #
      # - <code>:disabled</code> - If is set to <code>true</code>, the menu item is disabled.
      # - <code>:leading_icon</code> - The name of the leading icon.
      #
      # ==== Example
      #
      #   menu.item('Duplicate', href: '/copy', leading_icon: 'copy')
      #   # =>
      #   # <a is="haptic-menu-item" href="/duplicate">
      #   #   Duplicate
      #   #   <div class="haptic-icon leading-icon">copy</div>
      #   # </a>
      def item(name = nil, **options, &block)
        options, content_options = menu_item_options(options)
        @builder.tag.a(menu_item_content(name, content_options, &block), **options)
      end

      # Adds a menu item pointing to the URL specified by +options+.
      #
      # ==== HTML options
      #
      # - <code>:disabled</code> - If is set to <code>true</code>, the menu item is disabled.
      # - <code>:leading_icon</code> - The name of the leading icon.
      #
      # ==== Example
      #
      #   menu.item_to('Duplicate', '/copy', leading_icon: 'copy')
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
        options = @defaults.merge(options || {})
        options[:'data-disabled'] ||= '' if options.delete(:disabled)

        content_options = options.extract!(:leading_icon)

        [options, content_options]
      end
    end
  end
end
