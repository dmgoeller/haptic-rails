# frozen_string_literal: true

module Haptic
  module Rails
    class TableLikeBuilder
      def initialize(builder) # :nodoc:
        @builder = builder
      end

      # Adds a row.
      def row(**options, &block)
        @builder.tag.a(**options.merge(class: ['table-row', options[:class]]), &block)
      end

      # Adds a row pointing to +href+.
      def row_to(href, **options, &block)
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
