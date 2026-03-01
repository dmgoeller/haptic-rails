# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module NavHelper
        def haptic_nav(options = {})
          options = options.dup
          options[:is] = 'haptic-nav'
          builder_options = options.extract!(:defaults)

          content_tag('nav', options) do
            yield NavBuilder.new(self, builder_options) if block_given?
          end
        end
      end
    end
  end
end
