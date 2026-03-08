# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module NavHelper
        def haptic_nav(options = {})
          options = options.merge(is: 'haptic-nav')
          defaults = options.delete(:defaults)

          content_tag('nav', options) do
            yield NavBuilder.new(self, defaults) if block_given?
          end
        end
      end
    end
  end
end
