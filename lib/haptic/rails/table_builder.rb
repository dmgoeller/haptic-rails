# frozen_string_literal: true

module Haptic
  module Rails
    class TableBuilder
      def initialize(builder) # :nodoc:
        @builder = builder
      end

      # :call-seq: row(options = {}, &block)
      #
      # Creates a <code><tr></code> tag.
      def row(options = {})
        options = options.dup
        options[:is] = 'haptic-table-row'
        options[:'data-href'] ||= options.delete(:href)

        if block_given?
          @builder.content_tag('tr', options) do
            yield TableRowBuilder.new(@builder)
          end
        else
          @builder.content_tag('tr', '', options)
        end
      end
    end
  end
end
