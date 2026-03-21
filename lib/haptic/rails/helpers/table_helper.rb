# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module TableHelper
        # :call-seq: haptic-table(options = {}, &block)
        #
        # Creates a <code><table></code> tag.
        def haptic_table(options = {})
          content_tag('table', options.merge(is: 'haptic-table')) do
            yield TableBuilder.new(self) if block_given?
          end
        end

        # :call-seq: haptic-table_like(options = {}, &block)
        #
        # Creates a <code><haptic-table-like></code> tag.
        def haptic_table_like(options = {})
          content_tag('haptic-table-like', options) do
            yield TableLikeBuilder.new(self) if block_given?
          end
        end
      end
    end
  end
end
