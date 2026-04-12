# frozen_string_literal: true

module Haptic
  module Rails
    class TableRowBuilder
      def initialize(builder, model = nil) # :nodoc:
        @builder = builder
        @model = model
        @model_class = model.is_a?(Class) ? model : model.class
      end

      # :call-seq: data(content = nil, **options, &block)
      #
      # Adds a table cell.
      #
      # ==== Options
      #
      # - <code>:blank</code> - The representation of blank values.
      #
      # ==== Example
      #
      #   data('Data')
      #   # =>
      #   # <td>Data</td>
      def data(content = nil, blank: nil, **options, &block)
        content = @model.public_send(content) if @model && content.is_a?(Symbol)
        content = blank if content.blank? && blank.present?

        @builder.tag.send('td', content, **options, &block)
      end

      # Adds a table header.
      #
      # ==== Example
      #
      #   header('Header')
      #   # =>
      #   # <th>Header</th>
      def header(content = nil, **options, &block)
        if @model_class && content.is_a?(Symbol)
          content = @model_class.human_attribute_name(content)
        end
        @builder.tag.send('th', content, **options, &block)
      end
    end
  end
end
