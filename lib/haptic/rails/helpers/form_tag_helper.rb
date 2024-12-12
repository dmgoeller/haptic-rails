# frozen_string_literal: true

require_relative 'icon_helper'

module Haptic
  module Rails
    module Helpers
      module FormTagHelper
        include IconHelper

        def haptic_button_tag(content = nil, options = {})
          content, options = nil, content if content.is_a?(Hash)
          options = options.merge(is: 'haptic-button')
          icon = options.delete(:icon)

          content_tag('button', options) do
            concat haptic_icon_tag(icon, class: 'icon') if icon
            concat content if content
            yield if block_given?
          end
        end

        def haptic_check_box_tag(name, value = '1', checked = false, options = {})
          check_box_tag(name, value, checked, options.merge(is: 'haptic-input'))
        end

        def haptic_label_tag(name = nil, content_or_options = nil, options = nil, &block)
          content_or_options = content_options.merge(is: 'haptic-label') if content_or_options.is_a?(Hash)
          options = options.merge(is: 'haptic-label') if options.is_a?(Hash)
          label_tag(name, content_or_options, options, &block)
        end

        def haptic_radio_button_tag(name, value, checked = false, options = {})
          radio_button_tag(name, value, checked, options.merge(is: 'haptic-input'))
        end
      end
    end
  end
end
