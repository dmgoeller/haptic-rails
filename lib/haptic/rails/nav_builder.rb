# frozen_string_literal: true

module Haptic
  module Rails
    class NavBuilder
      def initialize(builder, **defaults) # :nodoc:
        @builder = builder
        @defaults = { is: 'haptic-nav-item', active_on: '_pathname' }
        @defaults.merge!(defaults) if defaults.present?
      end

      # Adds a nav item.
      #
      # ==== Options
      #
      # - <code>:leading_icon</code> - The name of the leading icon.
      #
      # ==== Example
      #
      #   nav.item('Home', href: '/', leading_icon: 'home')
      #   # =>
      #   # <a is="haptic-menu-item" href="/">
      #   #   Home
      #   #   <div class="haptic-icon leading-icon">home</div>
      #   # </a>
      def item(name = nil, **options, &block)
        options, content_options = nav_item_options(options)
        @builder.tag.a(nav_item_content(name, content_options, &block), **options)
      end

      # Adds a nav item pointing to the URL specified by +options+.
      #
      # ==== Options
      #
      # - <code>:leading_icon</code> - The name of the leading icon.
      #
      # ==== Example
      #
      #   nav.item_to('Home', '/', leading_icon: 'home')
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

      # Adds a section.
      #
      # ==== Example
      #
      #   nav_builder.section('Label') do
      #     nav_builder.item('Home', href: '/')
      #   end
      #   # =>
      #   # <div class="nav-section">
      #   #   <div class="nav-section-label">Label</div>
      #   #   <a is="haptic-nav-item" href="/" active-on="_pathname">Home</a>
      #   # </div>
      def section(label = nil, **options, &block)
        @builder.tag.div(
          if label.present?
            @builder.tag.div(label, class: 'nav-section-label')
          else
            ''.html_safe
          end + (@builder.capture(&block) if block),
          **options.merge(class: ['nav-section', options[:class]])
        )
      end

      private

      def nav_item_content(name, options, &block)
        (block ? @builder.capture(&block) : name.to_s.html_safe) +
          if (leading_icon = options[:leading_icon])
            @builder.haptic_icon_tag(leading_icon, class: 'leading-icon')
          end
      end

      def nav_item_options(options)
        options = @defaults.merge(options || {})
        options[:'active-on'] ||= options.delete(:active_on)

        content_options = options.extract!(:leading_icon)

        [options, content_options]
      end
    end
  end
end
