# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module DialogHelper
        def haptic_dialog(options = {})
          content_tag('dialog', options.merge(class: ['haptic-dialog', options[:class]])) do
            yield DialogBuilder.new(self) if block_given?
          end
        end
      end
    end
  end
end
