# frozen_string_literal: true

module Haptic
  module Rails
    class TableLikeBuilder
      def initialize(builder) # :nodoc:
        @builder = builder
      end

      def row(options = {}, &block)
        options = options.merge(class: ['table-row', options[:class]])

        if block
          @builder.content_tag('a', options, &block)
        else
          @builder.content_tag('a', '', options)
        end
      end

      def row_to(href, options = {}, &block)
        options = options.merge(class: ['table-row', options[:class]])

        if block
          @builder.link_to(href, options, &block)
        else
          @builder.link_to('', href, options)
        end
      end
    end
  end
end
