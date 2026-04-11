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
      # ==== Example
      #
      #   data('Data')
      #   # =>
      #   # <td>Data</td>
      def data(content = nil, blank: nil, **options, &block)
        if @model && content.is_a?(Symbol)
          content = @model.public_send(content)
          content = blank if content.blank? && blank.present?
        end
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
