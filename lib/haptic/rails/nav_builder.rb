# frozen_string_literal: true

module Haptic
  module Rails
    class NavBuilder
      def initialize(builder, defaults = {}) # :nodoc:
        @builder = builder
        @default_options = { is: 'haptic-nav-item', active_on: '_pathname' }
        @default_options.merge!(defaults) if defaults.present?
      end

      def item(name = nil, options = nil, &block)
        if block_given?
          name = nav_item_options(name)
        else
          options = nav_item_options(options)
        end
        @builder.content_tag('a', name, options, &block)
      end

      def item_to(name = nil, options = nil, html_options = nil, &block)
        if block_given?
          options = nav_item_options(options)
        else
          html_options = nav_item_options(html_options)
        end
        @builder.link_to(name, options, html_options, &block)
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

      def nav_item_options(options)
        options = @default_options.merge(options || {})
        options[:'active-on'] ||= options.delete(:active_on)
        options
      end
    end
  end
end
