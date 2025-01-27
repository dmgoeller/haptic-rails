# frozen_string_literal: true

module Haptic
  module Rails
    class PopoverBuilder
      def initialize(builder)
        @builder = builder
      end

      def segment(legend = nil, options = {}, &block)
        legend, options = nil, legend if legend.is_a?(Hash)

        @builder.content_tag('div', options.merge(class: ['segment', options[:class]])) do
          @builder.concat(@builder.content_tag('div', legend, class: 'legend')) if legend
          @builder.concat(@builder.capture(&block))
        end
      end
    end
  end
end
