# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module NavHelper
        def haptic_nav(options = {})
          content_tag('haptic-nav') do
            yield NavBuilder.new(self, options) if block_given?
          end
        end
      end
    end
  end
end
