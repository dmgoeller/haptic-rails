# frozen_string_literal: true

module Haptic
  module Rails
    class Configuration
      DEFAULT_ICON_BUILDER = lambda do |name, options = {}|
        options[:builder].content_tag(:div, name, options.except(:builder))
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

      def configure(&block)
        configuration.instance_eval(&block)
      end
    end
  end
end
