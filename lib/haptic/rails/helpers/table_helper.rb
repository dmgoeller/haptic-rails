# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module TableHelper
        # :call-seq: haptic-table(options = {}, &block)
        #
        # Creates a <code><table></code> tag.
        def haptic_table(options = {})
          options = options.stringify_keys
          options['is'] = 'haptic-table'

          content_tag('table', options) do
            yield TableBuilder.new(self) if block_given?
          end
        end
      end
    end
  end
end
