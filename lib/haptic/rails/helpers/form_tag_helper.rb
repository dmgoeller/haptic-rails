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

        def haptic_dialog_dropdown_tag(options = {}, &block)
          content_tag('haptic-dialog-dropdown', options) do
            concat capture(&block) if block
            concat content_tag('div', nil, class: 'backdrop')
          end
        end

        def haptic_dropdown_field_tag(field = nil, label = nil, options = {}, &block)
          haptic_field_tag('dropdown', field, label, options, &block)
        end

        def haptic_field_tag(type, field = nil, label = nil, options = {}, &block)
          field, label, options = capture(&block), field, label if block
          field = field.html_safe unless field.html_safe?

          label, options = nil, label if label.is_a?(Hash)
          options = options&.stringify_keys || {}

          field_options = options.except(
            'clear_button', 'error_message', 'leading_icon', 'show_error_icon',
            'show_error_message', 'supporting_text', 'trailing_icon'
          ).filter_map do |key, value|
            [key.dasherize, value == true ? '' : value] unless value == false
          end.to_h

          content_tag("haptic-#{type}-field", field_options) do
            content_tag('div', class: 'haptic-field-container') do
              field +
                if label
                  label.html_safe? ? label : content_tag('label', label, class: 'haptic-field-label')
                end +
                if type == 'text' && options['clear_button']
                  content_tag('button', type: 'button', tabindex: -1, class: 'clear-button') do
                    haptic_icon_tag('close')
                  end
                end +
                if options['show_error_icon']
                  haptic_icon_tag('error', class: 'error-icon')
                end +
                if (leading_icon = options['leading_icon'])
                  haptic_icon_tag(leading_icon, class: 'leading-icon')
                end +
                if type == 'text' && (trailing_icon = options['trailing_icon'])
                  haptic_icon_tag(trailing_icon, class: 'trailing-icon')
                end
            end +
              if options['show_error_message'] && options['error_message'].present?
                content_tag('div', options['error_message'], class: 'error-message')
              end +
              if (supporting_text = options['supporting_text'])
                content_tag('div', supporting_text, class: 'supporting-text')
              end
          end
        end

        def haptic_list_tag(options = {}, &block)
          options = options.stringify_keys
          options['required'] = '' if options['required'] == true

          content_tag('haptic-list', options, &block)
        end

        def haptic_list_item_tag(content = nil, options = nil, &block)
          content_tag('haptic-list-item', content, options, &block)
        end

        def haptic_segmented_button_tag(options = {}, &block)
          content_tag('haptic-segmented-button', options, &block)
        end

        def haptic_select_dropdown_tag(options = {}, &block)
          content_tag('haptic-select-dropdown', options) do
            concat capture(&block) if block
            concat content_tag('div', nil, class: 'backdrop')
          end
        end

        def haptic_text_field_tag(field = nil, label = nil, options = {}, &block)
          haptic_field_tag('text', field, label, options, &block)
        end
      end
    end
  end
end
