# frozen_string_literal: true

require_relative 'icon_helper'

module Haptic
  module Rails
    module Helpers
      module TagHelper
        include IconHelper

        # Creates a <code><haptic-button-segment></code> tag.
        def haptic_button_segment_tag(content = nil, options = nil, &block)
          content_tag('haptic-button-segment', content, options, &block)
        end

        # Creates a <code><haptic-chip></code> tag.
        def haptic_chip_tag(content = nil, options = nil, &block)
          content_tag('haptic-chip', content, options, &block)
        end

        # Creates a <code><haptic-dialog-dropdown></code> tag.
        #
        # Same as <code>haptic_dropdown('dialog', options, &block)</code>.
        #
        # # ==== Options
        #
        # - <code>:to_top</code> - If is <code>true</code>, the popover pops up to top
        #   instead of to bottom.
        def haptic_dialog_dropdown_tag(options = {}, &block)
          options = options.stringify_keys
          options['to-top'] = '' if options.delete('to_top')

          haptic_dropdown_tag('dialog', options, &block)
        end

        # Creates a <code>haptic-dropdown</code>, <code>haptic-dialog-dropdown</code> or
        # <code>haptic-select-dropdown</code> tag.
        #
        # <code>type</code> can be <code>'dialog'</code>, <code>'select'</code> or
        # <code>nil</code>.
        #
        # ==== Example
        #
        #   haptic_dropdown_tag do
        #     content_tag 'div', class: 'toggle' do
        #       # ...
        #     end +
        #     content_tag 'div', class: 'popover' do
        #       # ...
        #     end
        #   end
        #   # =>
        #   # <haptic-dropdown>
        #   #   <div class="toggle"></div>
        #   #   <div class="popover"></div>
        #   #   <div class="backdrop"></div>
        #   # </haptic-dropdown>
        def haptic_dropdown_tag(type = nil, options = {}, &block)
          type, options = nil, type if type.is_a?(Hash)
          name = type ? "haptic-#{type}-dropdown" : 'haptic-dropdown'

          content_tag(name, options) do
            concat capture(&block) if block
            concat content_tag('div', nil, class: 'backdrop')
          end
        end

        # Creates a <code><haptic-dropdown-field></code> tag wrapping the given field.
        #
        # Same as <code>haptic_field_tag('dropdown', field, label, options, &block)</code>.
        def haptic_dropdown_field_tag(field = nil, label = nil, options = nil, &block)
          haptic_field_tag('dropdown', field, label, options, &block)
        end

        # Creates a <code><haptic-text-field></code> or <code>haptic-dropdown-field</code> tag
        # wrapping the given field.
        #
        # <code>type</code> can be <code>'text'</code> or <code>'dropdown'</code>.
        #
        # ==== Options
        #
        # - <code>:animated_label</code>
        # - <code>:clear_button</code>
        # - <code>:error_message</code>
        # - <code>:focus_indicator</code>
        # - <code>:leading_icon</code>
        # - <code>:set_valid_on_change</code>
        # - <code>:show_error_icon</code>
        # - <code>:show_error_message</code>
        # - <code>:supporting_text</code>
        # - <code>:trailing_icon</code>
        #
        # ==== Examples
        #
        #   haptic_field_tag('text') { text_field_tag 'name' }
        #   # =>
        #   # <haptic-text-field>
        #   #   <div class="field-container">
        #   #     <input id="name" name="name" type="text">
        #   #   </div>
        #   # </haptic-text-field>
        #
        #   haptic_field_tag('text', 'Label') { text_field_tag 'name' }
        #   # =>
        #   # <haptic-text-field>
        #   #   <div class="field-container">
        #   #     <input id="name" name="name" type="text">
        #   #     <label class="field-label">Label</label>
        #   #   </div>
        #   # </haptic-text-field>
        #
        #   haptic_field_tag('text', clear_button: true) { text_field_tag 'name' }
        #   # =>
        #   # <haptic-text-field>
        #   #   <div class="field-container">
        #   #     <input id="name" name="name" type="text">
        #   #     <button type="button" tabindex="-1" class="clear-button">
        #   #       <div class="haptic-icon">close</div>
        #   #     </button>
        #   #   </div>
        #   # </haptic-text-field>
        def haptic_field_tag(type = 'text', field = nil, label = nil, options = nil, &block)
          field, label, options = capture(&block), field, label if block
          field = '' if field.nil?
          field = field.html_safe unless field.html_safe?

          label, options = nil, label if label.is_a?(Hash)
          options = (options || {}).stringify_keys

          field_options = options.except(
            'clear_button', 'error_message', 'leading_icon', 'show_error_icon',
            'show_error_message', 'supporting_text', 'trailing_icon'
          ).filter_map do |key, value|
            [key.dasherize, value == true ? '' : value] unless value == false
          end.to_h

          content_tag("haptic-#{type}-field", field_options) do
            content_tag('div', class: 'field-container') do
              field +
                if label
                  label.html_safe? ? label : content_tag('label', label, class: 'field-label')
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

        # Creates a <code><haptic-list></code> tag.
        def haptic_list_tag(content = nil, options = nil, &block)
          content_tag('haptic-list', content, options, &block)
        end

        # Creates a <code><haptic-list-item></code> tag.
        def haptic_list_item_tag(content = nil, options = nil, &block)
          content_tag('haptic-list-item', content, options, &block)
        end

        # Creates a <code><haptic-option-list></code> tag.
        def haptic_option_list_tag(content = nil, options = nil, &block)
          content_tag('haptic-option-list', content, options, &block)
        end

        # Creates a <code><haptic-option></code> tag.
        #
        # ==== Options
        #
        # - <code>:checked</code> - If is <code>true</code>, the option is checked initially.
        def haptic_option_tag(content = nil, options = nil, &block)
          content_tag('haptic-option', content, options, &block)
        end

        # Creates a <code><haptic-segmented-button></code> tag.
        def haptic_segmented_button_tag(content = nil, options = nil, &block)
          content_tag('haptic-segmented-button', content, options, &block)
        end

        # Creates a <code><haptic-select-dropdown></code> tag.
        #
        # Same as <code>haptic_dropdown('select', options, &block)</code>.
        def haptic_select_dropdown_tag(options = {}, &block)
          haptic_dropdown_tag('select', options, &block)
        end

        # Creates a <code><haptic-text-field></code> tag wrapping the given field.
        #
        # Same as <code>haptic_field_tag('text', field, label, options, &block)</code>.
        def haptic_text_field_tag(field = nil, label = nil, options = nil, &block)
          haptic_field_tag('text', field, label, options, &block)
        end
      end
    end
  end
end
