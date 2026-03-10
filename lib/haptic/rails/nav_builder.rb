# frozen_string_literal: true

module Haptic
  module Rails
    class NavBuilder
      def initialize(builder, defaults = {}) # :nodoc:
        @builder = builder
        @default_options = { is: 'haptic-nav-item', active_on: '_pathname' }
        @default_options.merge!(defaults) if defaults.present?
      end

      # Creates a nav item.
      #
      # ==== Options
      #
      # - <code>:leading_icon</code> - The name of the leading icon.
      #
      # ==== Example
      #
      #   nav.item 'Home', href: '/', leading_icon: 'home'
      #   # =>
      #   # <a is="haptic-menu-item" href="/">
      #   #   Home
      #   #   <div class="haptic-icon leading-icon">home</div>
      #   # </a>
      def item(name = nil, options = nil, &block)
        name, options = nil, name if block
        options, content_options = nav_item_options(options)

        @builder.content_tag('a', options) do
          nav_item_content(name, content_options, &block)
        end
      end

      # Creates a nav item pointing to the URL specified by +options+.
      #
      # ==== Options
      #
      # - <code>:leading_icon</code> - The name of the leading icon.
      #
      # ==== Example
      #
      #   nav.item_to 'Home', '/', leading_icon: 'home'
      #   # =>
      #   # <a is="haptic-menu-item" href="/">
      #   #   Home
      #   #   <div class="haptic-icon leading-icon">home</div>
      #   # </a>
      def item_to(name = nil, options = nil, html_options = nil, &block)
        name, options, html_options = nil, name, options if block
        html_options, content_options = nav_item_options(html_options)

        @builder.link_to(options, html_options) do
          nav_item_content(name, content_options, &block)
        end
      end

      def section(label = nil, &block)
        @builder.content_tag('div', class: 'nav-section') do
          @builder.concat(
            @builder.content_tag('div', label, class: 'nav-section-label')
          ) if label.present?
          @builder.concat(@builder.capture(&block))
        end
      end

      private

      def nav_item_content(name, options, &block)
        (block ? @builder.capture(&block) : name.to_s.html_safe) +
          if (leading_icon = options[:leading_icon])
            @builder.haptic_icon_tag(leading_icon, class: 'leading-icon')
          end
      end

      def nav_item_options(options)
        options = @default_options.merge(options || {})
        options[:'active-on'] ||= options.delete(:active_on)

        content_options = options.extract!(:leading_icon)

        [options, content_options]
      end
    end
  end
end
