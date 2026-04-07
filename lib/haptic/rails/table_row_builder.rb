# frozen_string_literal: true

module Haptic
  module Rails
    class TableRowBuilder
      def initialize(builder) # :nodoc:
        @builder = builder
      end

      ##
      # :method: data
      # :call-seq: data(content, **options, &block)
      #
      # Adds a table cell.
      #
      # ==== Example
      #
      #   data('Data')
      #   # =>
      #   # <td>Data</td>

      ##
      # :method: head
      # :call-seq: head(content, **options, &block)
      #
      # Adds a table header.
      #
      # ==== Example
      #
      #   header('Header')
      #   # =>
      #   # <th>Header</th>

      { data: 'td', header: 'th' }.each do |name, tag_name|
        define_method(name) do |content = nil, **options, &block|
          @builder.tag.send(tag_name, content, **options, &block)
        end
      end
    end
  end
end
