# frozen_string_literal: true

require_relative 'icon_helper'

module Haptic
  module Rails
    module Helpers
      module ButtonHelper
        include IconHelper

        def haptic_button(content = nil, options = {})
          content, options = nil, content if content.is_a?(Hash)
          options = options.merge(is: 'haptic-button')
          icon = options.delete(:icon)

          content_tag('button', options) do
            concat haptic_icon(icon) if icon
            concat content if content
            yield if block_given?
          end
        end
      end
    end
  end
end
