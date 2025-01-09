# frozen_string_literal: true

module Haptic
  module Rails
    class PopoverBuilder
      def initialize(builder)
        @builder = builder
      end

      def segment(legend = nil, options = {}, &block)
        legend, options = nil, legend if legend.is_a?(Hash)
        options = options.merge(class: [options[:class], 'segment'].flatten)

        @builder.content_tag('div', options) do
          @builder.concat(@builder.content_tag('div', legend, class: 'legend')) if legend
          block&.call
        end
      end
    end
  end
end
