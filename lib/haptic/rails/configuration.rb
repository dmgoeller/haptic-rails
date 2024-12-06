# frozen_string_literal: true

module Haptic
  module Rails
    class Configuration
      DEFAULT_ICON_BUILDER = lambda do |name, options = {}|
        options[:builder].content_tag(:div, name, class: "#{options[:class]} haptic-icon")
      end

      attr_writer :icon_builder

      # arrow_drop_down, close, error, search
      def icon_builder
        @icon_builder || DEFAULT_ICON_BUILDER
      end
    end
  end
end
