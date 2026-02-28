# frozen_string_literal: true

module Haptic
  module Rails
    class NavBuilder
      def initialize(builder, options = {}) # :nodoc:
        defaults = options[:defaults]

        @builder = builder
        @defaults = { is: 'haptic-nav-item', active_on: '_pathname' }
        @defaults.merge!(defaults) if defaults
      end

      def item(name = nil, options = nil, html_options = nil, &block)
        if block_given?
          options = item_options(options)
        else
          html_options = item_options(html_options)
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

      def item_options(options)
        options = @defaults.merge(options || {})
        options[:'active-on'] ||= options.delete(:active_on)
        options
      end
    end
  end
end
