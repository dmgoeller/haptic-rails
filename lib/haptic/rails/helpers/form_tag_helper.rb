# frozen_string_literal: true

require_relative 'icon_helper'

module Haptic
  module Rails
    module Helpers
      module FormTagHelper
        include IconHelper

        def haptic_button_tag(content = nil, options = {}, &block)
          content, options = capture(&block), content if block
          options = options&.stringify_keys || {}
          options['is'] = 'haptic-button'
          icon = options.delete('icon')

          content_tag('button', options) do
            concat haptic_icon_tag(icon, class: 'icon') if icon
            concat content if content
          end
        end

        def haptic_text_field_tag(field = nil, label = nil, options = {}, &block)
          field, label, options = capture(&block), field, label if block
          field = field.html_safe unless field.html_safe?
          options = options&.stringify_keys || {}
          error = options['error_message'].present?

          text_field_options = options.slice('for', 'reset_error_on_change')
          text_field_options['animated'] = '' if options['animated']
          text_field_options['focus-indicator'] = '' if options['focus_indicator']
          text_field_options['error'] = '' if error

          content_tag('haptic-text-field', text_field_options.transform_keys(&:dasherize)) do
            content_tag('div', class: 'container') do
              field +
                if label
                  label.html_safe? ? label : content_tag('label', label)
                end +
                if options['clear_button']
                  haptic_icon_tag('close', class: 'clear-button')
                end +
                if options['show_error_icon'] && error
                  haptic_icon_tag('error', class: 'error-icon')
                end +
                if (leading_icon = options['leading_icon'])
                  haptic_icon_tag(leading_icon, class: 'leading-icon')
                end +
                if (trailing_icon = options['trailing_icon'])
                  haptic_icon_tag(trailing_icon, class: 'trailing-icon')
                end
            end +
              if options['show_error_message'] && error
                content_tag('div', options['error_message'], class: 'error-message')
              end +
              if (supporting_text = options['supporting_text'])
                content_tag('div', supporting_text, class: 'supporting-text')
              end
          end
        end
      end
    end
  end
end
