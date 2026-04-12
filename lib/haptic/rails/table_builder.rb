# frozen_string_literal: true

module Haptic
  module Rails
    class TableBuilder
      def initialize(builder) # :nodoc:
        @builder = builder
      end

      # :call-seq: row(model: nil, **options, &block)
      #
      # Adds a row. If a block is given, it is called with an instance of TableRowBuilder
      # as argument.
      #
      # ==== Options
      #
      # - <code>:href</code> - The URL the row points to.
      # - <code>:model</code> - The model.
      def row(href: nil, model: nil, **options)
        options = options.reverse_merge('data-href': href) if href

        @builder.tag.tr('tr', is: 'haptic-table-row', **options) do
          yield TableRowBuilder.new(@builder, model) if block_given?
        end
      end

      # Adds a row for +model+. If a block is given, it is called with an instance of
      # TableRowBuilder as argument.
      #
      # ==== Options
      #
      # - <code>:href</code> - The URL the row points to.
      def row_for(model, **options, &block)
        row(model: model, **options, &block)
      end
    end
  end
end
