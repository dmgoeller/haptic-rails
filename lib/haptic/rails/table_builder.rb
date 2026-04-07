# frozen_string_literal: true

module Haptic
  module Rails
    class TableBuilder
      def initialize(builder) # :nodoc:
        @builder = builder
      end

      # :call-seq: row(**options, &block)
      #
      # Adds a row. Passes an instance of TableRowBuilder to the block.
      #
      # ==== Options
      #
      # - <code>:href</code>
      def row(**options)
        options = options.merge(is: 'haptic-table-row')
        options[:'data-href'] ||= options.delete(:href)

        @builder.tag.tr('tr', **options) do
          yield TableRowBuilder.new(@builder) if block_given?
        end
      end
    end
  end
end
