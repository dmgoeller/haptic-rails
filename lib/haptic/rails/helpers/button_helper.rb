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
            concat haptic_icon(icon, class: 'icon') if icon
            concat content if content
            yield if block_given?
          end
        end

        def haptic_toolbutton(content = nil, options = {})
          content, options = nil, content if content.is_a?(Hash)
          options = options.merge(
            is: 'haptic-button',
            class: ['haptic-toolbutton', options[:class]].flatten
          )
          content_tag('button', options) do
            concat content if content
            yield if block_given?
          end
        end
      end
    end
  end
end
