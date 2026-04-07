# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module TableHelper
        # :call-seq: haptic-table(**options, &block)
        #
        # Creates a haptic table. Passes an instance of TableBuilder to the block.
        def haptic_table(**options)
          tag.table(**options.merge(is: 'haptic-table')) do
            yield TableBuilder.new(self) if block_given?
          end
        end

        # :call-seq: haptic-table_like(**options, &block)
        #
        # Creates a haptic table-like element. Passes an instance of TableLikeBuilder
        # to the block.
        def haptic_table_like(**options)
          tag.haptic_table_like(**options) do
            yield TableLikeBuilder.new(self) if block_given?
          end
        end
      end
    end
  end
end
