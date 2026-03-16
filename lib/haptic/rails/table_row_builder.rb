# frozen_string_literal: true

module Haptic
  module Rails
    class TableRowBuilder
      def initialize(builder) # :nodoc:
        @builder = builder
      end

      ##
      # :method: data
      # :call-seq: data(content, options = nil, &block)
      #
      # Creates a <code><td></code> tag.

      ##
      # :method: head
      # :call-seq: head(content, options = {}, &block)
      #
      # Creates a <code><th></code> tag.

      [[:data, 'td'], [:header, 'th']].each do |name, tag_name|
        define_method(name) do |content = nil, options = nil, &block|
          content, options = nil, content if content.is_a?(Hash)

          @builder.content_tag(tag_name, content, options, &block)
        end
      end
    end
  end
end
