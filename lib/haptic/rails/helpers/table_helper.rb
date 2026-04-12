# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module TableHelper
        # :call-seq: haptic-table(**options, &block)
        #
        # Creates a haptic table. If a block is given, it is called with an instance of
        # TableBuilder as argument.
        def haptic_table(**options)
          tag.table(is: 'haptic-table', **options) do
            yield TableBuilder.new(self) if block_given?
          end
        end

        # :call-seq: haptic-table_like(**options, &block)
        #
        # Creates a haptic table-like element. If a block is given, it is called with an
        # instance of TableLikeBuilder as argument.
        def haptic_table_like(**options)
          tag.haptic_table_like(**options) do
            yield TableLikeBuilder.new(self) if block_given?
          end
        end
      end
    end
  end
end
