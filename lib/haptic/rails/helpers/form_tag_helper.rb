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

        def haptic_error_tag(message, options = {})
          content_tag('div', message, options.merge(class: [options[:class], 'error']))
        end

        def haptic_label_tag(name = nil, content_or_options = nil, options = nil, &block)
          if content_or_options.is_a?(Hash)
            content_or_options = content_options.merge(is: 'haptic-label')
          else
            options = (options || {}).merge(is: 'haptic-label')
          end
          label_tag(name, content_or_options, options, &block)
        end

        def haptic_radio_button_tag(name, value, checked = false, options = {})
          radio_button_tag(name, value, checked, options.merge(is: 'haptic-input'))
        end

        def haptic_text_field_tag(field = nil, label = nil, options = {}, &block)
          field, label, options = capture(&block), field, label if block
          field = field.html_safe unless field.html_safe?

          options ||= {}
          errors = options[:errors]

          text_field_options = {}
          text_field_options['with-errors'] = '' if errors
          text_field_options['animated'] = '' if options[:animated]
          text_field_options['focus-indicator'] = '' if options[:focus_indicator]
          text_field_options['reset-errors-on-change'] = options[:reset_errors_on_change]

          content_tag('haptic-text-field', text_field_options) do
            content_tag('div', class: 'container') do
              field +
                if label
                  label.html_safe? ? label : content_tag('label', label)
                end +
                if options[:clear_button]
                  haptic_icon_tag('close', class: 'clear-button')
                end +
                if options[:error_icon] && errors
                  haptic_icon_tag('error', class: 'error-icon')
                end +
                if (leading_icon = options[:leading_icon])
                  haptic_icon_tag(leading_icon, class: 'leading-icon')
                end +
                if (trailing_icon = options[:trailing_icon])
                  haptic_icon_tag(trailing_icon, class: 'trailing-icon')
                end
            end +
              if options[:error_messages] && errors
                haptic_error_tag(errors, class: 'supporting-text')
              end +
              if (supporting_text = options[:supporting_text])
                content_tag('div', supporting_text, class: 'supporting-text')
              end
          end
        end
      end
    end
  end
end
