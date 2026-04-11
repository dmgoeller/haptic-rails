# frozen_string_literal: true

module Haptic
  module Rails
    class TableBuilder
      def initialize(builder) # :nodoc:
        @builder = builder
      end

      # :call-seq: row(model: nil, **options, &block)
      #
      # Adds a row. Passes an instance of TableRowBuilder to the block.
      #
      # ==== Options
      #
      # - <code>:href</code>
      # - <code>:model</code>
      def row(href: nil, model: nil, **options)
        options = options.reverse_merge('data-href': href) if href

        @builder.tag.tr('tr', is: 'haptic-table-row', **options) do
          yield TableRowBuilder.new(@builder, model) if block_given?
        end
      end

      # Adds a row for +model+. Passes an instance of TableRowBuilder to the block.
      #
      # ==== Options
      #
      # - <code>:href</code>
      def row_for(model, **options, &block)
        row(model: model, **options, &block)
      end
    end
  end
end
