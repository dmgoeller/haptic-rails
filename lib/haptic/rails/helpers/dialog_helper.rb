# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module DialogHelper
        # :call-seq: haptic_dialog(**options, &block)
        #
        # Creates a haptic dialog. If a block is given, it is called with an instance of
        # DialogBuilder as argument.
        def haptic_dialog(**options)
          tag.dialog(**options.merge(class: ['haptic-dialog', options[:class]])) do
            yield DialogBuilder.new(self) if block_given?
          end
        end
      end
    end
  end
end
