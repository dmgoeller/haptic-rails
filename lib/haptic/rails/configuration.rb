# frozen_string_literal: true

module Haptic
  module Rails
    class Configuration
      DEFAULT_ICON_BUILDER = lambda do |name, options = {}|
        builder = options[:builder]

        builder.content_tag(
          :div,
          name,
          class: builder.haptic_css_class(options[:class], 'haptic-icon')
        )
      end

      attr_writer :icon_builder

      # arrow_drop_down, close, error
      def icon_builder
        @icon_builder || DEFAULT_ICON_BUILDER
      end
    end

    class << self
      # The singleton \Haptic \Rails configuration.
      def configuration
        @configuration ||= Configuration.new
      end
    end
  end
end
