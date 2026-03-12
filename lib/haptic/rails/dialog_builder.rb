# frozen_string_literal: true

module Haptic
  module Rails
    class DialogBuilder
      def initialize(builder) # :nodoc:
        @builder = builder
      end

      def header(content = nil, options = {}, &block)
        content, options = nil, content if content.is_a?(Hash)
        options = options.merge(class: ['dialog-header', options[:class]])

        @builder.content_tag('div', content, options, &block)
      end

      def segment(legend = nil, options = {}, &block)
        legend, options = nil, legend if legend.is_a?(Hash)
        options = options.merge(class: ['dialog-segment', options[:class]])

        @builder.content_tag('div', options) do
          @builder.concat(@builder.content_tag('div', legend, class: 'legend')) if legend
          @builder.concat(@builder.capture(&block)) if block
        end
      end
    end
  end
end
