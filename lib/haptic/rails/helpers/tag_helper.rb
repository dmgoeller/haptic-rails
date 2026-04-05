# frozen_string_literal: true

require_relative 'icon_helper'

module Haptic
  module Rails
    module Helpers
      module TagHelper
        include IconHelper

        ##
        # :method: haptic_button_segment_tag
        # :call-seq:
        #   haptic_button_segment_tag(content = nil, options = nil)
        #   haptic_button_segment_tag(options = nil, &block)
        #
        # Creates a <code><haptic-button-segment></code> tag.
        #
        # ==== Example
        #
        #   haptic_button_segment_tag(
        #     tag.input(type: 'radio', name: 'color', value: 'blue') + tag.label('Blue')
        #   )
        #   # =>
        #   # <haptic-button-segment>
        #   #   <input type="radio" name="color" value="blue">
        #   #   <label>Blue</label>
        #   # </haptic-button-segment>

        ##
        # :method: haptic_chip_tag
        # :call-seq:
        #   haptic_chip_tag(content = nil, options = nil)
        #   haptic_chip_tag(options = nil, &block)
        #
        # Creates a <code><haptic-chip></code> tag.
        #
        # ==== Example
        #
        #   haptic_chip_tag(
        #     tag.input(type: 'checkbox', name: 'color', value: 'blue') + tag.label('Blue')
        #   )
        #   # =>
        #   # <haptic-chip>
        #   #   <input type="checkbox" name="color" value="blue">
        #   #   <label>Blue</label>
        #   # </haptic-chip>

        ##
        # :method: haptic_list_item_tag
        # :call-seq:
        #   haptic_list_item_tag(content = nil, options = nil)
        #   haptic_list_item_tag(options = nil, &block)
        #
        # Creates a <code><haptic-list-item></code> tag.
        #
        # ==== Example
        #
        #   haptic_list_item_tag(
        #     tag.input(type: 'radio', name: 'color', value: 'blue') + tag.label('Blue')
        #   )
        #   # =>
        #   # <haptic-list-item>
        #   #   <input type="radio" name="color" value="blue">
        #   #   <label>Blue</label>
        #   # </haptic-list-item>

        ##
        # :method: haptic_list_tag
        # :call-seq:
        #   haptic_list_tag(content = nil, options = nil)
        #   haptic_list_tag(options = nil, &block)
        #
        # Creates a <code><haptic-list></code> tag.
        #
        # ==== Example
        #
        #   haptic_list_tag(
        #     haptic_list_item_tag(
        #       tag.input(type: 'radio', name: 'color', value: 'blue') + tag.label('Blue')
        #     ) +
        #     haptic_list_item_tag(
        #       tag.input(type: 'radio', name: 'color', value: 'green') + tag.label('Green')
        #     )
        #   )
        #   # =>
        #   # <haptic-list>
        #   #   <haptic-list-item>
        #   #     <input type="radio" name="color" value="blue">
        #   #     <label>Blue</label>
        #   #   </haptic-list-item>
        #   #   <haptic-list-item>
        #   #     <input type="radio" name="color" value="green">
        #   #     <label>Green</label>
        #   #   </haptic-list-item>
        #   # </haptic-list>

        ##
        # :method: haptic_menu_tag
        # :call-seq:
        #   haptic_menu_tag(content = nil, options = nil)
        #   haptic_menu_tag(options = nil, &block)
        #
        # Creates a <code><haptic-menu></code> tag.
        #
        # ==== Example
        #
        #   haptic_menu_tag(link_to('Delete', '/delete', is: 'haptic-menu-item'))
        #   # =>
        #   # <haptic-menu>
        #   #   <a is="haptic-menu-item" href="/delete">Delete</a>
        #   # </haptic-menu>

        ##
        # :method: haptic_option_tag
        # :call-seq:
        #   haptic_option_tag(content = nil, options = nil)
        #   haptic_option_tag(options = nil, &block)
        #
        # ==== Options
        #
        # - <code>:checked</code> - If is set to <code>true</code>, the option is
        #   checked initially.
        # - <code>:disabled</code> - If is set to <code>true</code>, the option is
        #   disabled.
        # - <code>:value</code> - The value of the option.
        #
        # Creates a <code><haptic-option></code> tag.
        #
        # ==== Examples
        #
        #   haptic_option_tag('Blue', value: 'blue')
        #   # =>
        #   # <haptic-option value="blue">Blue</haptic-option>
        #
        #   haptic_option_tag('Blue', checked: true, value: 'blue')
        #   # =>
        #   # <haptic-option checked="checked" value="blue">Blue</haptic-option>

        ##
        # :method: haptic_segmented_button_tag
        # :call-seq:
        #   haptic_segmented_button_tag(content = nil, options = nil)
        #   haptic_segmented_button_tag(options = nil, &block)
        #
        # Creates a <code><haptic-segmented-button></code> tag.
        #
        # ==== Example
        #
        #   haptic_segmented_button_tag(
        #     haptic_button_segment_tag(
        #       tag.input(type: 'radio', name: 'color', value: 'blue') + tag.label('Blue')
        #     ) +
        #     haptic_button_segment_tag(
        #       tag.input(type: 'radio', name: 'color', value: 'green') + tag.label('Green')
        #     )
        #   )
        #   # =>
        #   # <haptic-segmented-button>
        #   #   <haptic-button-segment>
        #   #     <input type="radio" name="color" value="blue">
        #   #     <label>Blue</label>
        #   #   </haptic-button-segment>
        #   #   <haptic-button-segment>
        #   #     <input type="radio" name="color" value="green">
        #   #     <label>Green</label>
        #   #   </haptic-button-segment>
        #   # </haptic-segmented-button>

        ##
        # :method: haptic_tab_bar_tag
        # :call-seq:
        #   haptic_tab_bar_tag(content = nil, options = nil)
        #   haptic_tab_bar_tag(options = nil, &block)
        #
        # Creates a <code><haptic-tab-bar></code> tag.
        #
        # ==== Example
        #
        #   haptic_tab_bar_tag(
        #     tag.div('Overview', class: 'haptic-tab') +
        #     tag.div('Specifications', class: 'haptic-tab')
        #   )
        #   # =>
        #   # <haptic-tab-bar>
        #   #   <div class="haptic-tab">Overview</div>
        #   #   <div class="haptic-tab">Specifications</div>
        #   # </haptic-tab-bar>

        ##
        # :method: haptic_tabs_tag
        # :call-seq:
        #   haptic_tabs_tag(content = nil, options = nil)
        #   haptic_tabs_tag(options = nil, &block)
        #
        # Creates a <code><haptic-tabs></code> tag.
        #
        # ==== Example
        #
        #   haptic_tabs_tag(
        #     haptic_tab_bar_tag(
        #       tag.div('Overview', class: 'haptic-tab') +
        #       tag.div('Specifications', class: 'haptic-tab')
        #     ) +
        #     tag.div('Overview', class: 'haptic-tab-content') +
        #     tag.div('Specifications', class: 'haptic-tab-content')
        #   )
        #   # =>
        #   # <haptic-tabs>
        #   #   <haptic-tab-bar>
        #   #     <div class="haptic-tab">Overview</div>
        #   #     <div class="haptic-tab">Specifications</div>
        #   #   </haptic-tab-bar>
        #   #   <div class="haptic-tab-content">Overview</div>
        #   #   <div class="haptic-tab-content">Specifications</div>
        #   # </haptic-tabs>

        %w[
          haptic-button-segment
          haptic-chip
          haptic-list
          haptic-list-item
          haptic-menu
          haptic-option
          haptic-segmented-button
          haptic-tab-bar
          haptic-tabs
        ].each do |tag_name|
          define_method(:"#{tag_name.underscore}_tag") do |content = nil, options = nil, &block|
            content, options = nil, content if content.is_a?(Hash)
            content_tag(tag_name, content, options, &block)
          end
        end

        ##
        # :method: haptic_dropdown_dialog_tag
        # :call-seq:
        #   haptic_dropdown_dialog_tag(content = nil, options = nil)
        #   haptic_dropdown_dialog_tag(options = nil, &block)
        #
        # Creates a <code><haptic-dropdown-dialog></code> tag.
        #
        # ==== Options
        #
        # - <code>:open_to_top</code> - If is set to <code>true</code>, the dialog pops up
        #   to top instead of to bottom.
        #
        # ==== Examples
        #
        #   haptic_dropdown_dialog_tag(tag.div(class: 'toggle') + tag.div(class: 'popover'))
        #   # =>
        #   # <haptic-dropdown-dialog>
        #   #   <div class="toggle"></div>
        #   #   <div class="popover"></div>
        #   #   <div class="backdrop"></div>
        #   # </haptic-dropdown-dialog>
        #
        #   haptic_dropdown_dialog_tag(
        #     tag.div(class: 'toggle') + tag.div(class: 'popover'),
        #     open_to_top: true
        #   )
        #   # =>
        #   # <haptic-dropdown-dialog open-to-top>
        #   #   <div class="toggle"></div>
        #   #   <div class="popover"></div>
        #   #   <div class="backdrop"></div>
        #   # </haptic-dropdown-dialog>

        ##
        # :method: haptic_dropdown_menu_tag
        # :call-seq:
        #   haptic_dropdown_menu_tag(content = nil, options = nil)
        #   haptic_dropdown_menu_tag(options = nil, &block)
        #
        # Creates a <code><haptic-dropdown-menu></code> tag.
        #
        # ==== Options
        #
        # - <code>:open_to_top</code> - If is set to <code>true</code>, the menu pops up
        #   to top instead of to bottom.
        #
        # ==== Examples
        #
        #   haptic_dropdown_menu_tag(tag.div(class: 'toggle') + tag.div(class: 'popover'))
        #   # =>
        #   # <haptic-dropdown-menu>
        #   #   <div class="toggle"></div>
        #   #   <div class="popover"></div>
        #   #   <div class="backdrop"></div>
        #   # </haptic-dropdown-menu>
        #
        #   haptic_dropdown_menu_tag(
        #     tag.div(class: 'toggle') + tag.div(class: 'popover'),
        #     open_to_top: true
        #   )
        #   # =>
        #   # <haptic-dropdown-menu open-to-top>
        #   #   <div class="toggle"></div>
        #   #   <div class="popover"></div>
        #   #   <div class="backdrop"></div>
        #   # </haptic-dropdown-menu>

        ##
        # :method: haptic_select_dropdown_tag
        # :call-seq:
        #   haptic_select_dropdown_tag(content = nil, options = nil)
        #   haptic_select_dropdown_tag(options = nil, &block)
        #
        # Creates a <code><haptic-select-dropdown></code> tag.
        #
        # ==== Example
        #
        #   haptic_select_dropdown(tag.div(class: 'toggle') + tag.div(class: 'popover'))
        #   # =>
        #   # <haptic-select-dropdown>
        #   #   <div class="toggle"></div>
        #   #   <div class="popover"></div>
        #   #   <div class="backdrop"></div>
        #   # </haptic-select-dropdown>

        %w[
          haptic-dropdown
          haptic-dropdown-dialog
          haptic-dropdown-menu
          haptic-select-dropdown
        ].each do |tag_name|
          define_method(:"#{tag_name.underscore}_tag") do |content = nil, options = nil, &block|
            content, options = capture(&block), content if block
            content, options = '', content if content.is_a?(Hash)
            content = (content || '').html_safe unless content&.html_safe?

            if options && tag_name.in?(%w[haptic-dropdown-dialog haptic-dropdown-menu])
              options = options.stringify_keys
              options['open-to-top'] ||= '' if options.delete('open_to_top')
            end

            content_tag(tag_name, content + tag.div(class: 'backdrop'), options)
          end
        end

        ##
        # :method: haptic_dropdown_field_tag
        # :call-seq:
        #   haptic_dropdown_field_tag(field = nil, label = nil, options = nil)
        #   haptic_dropdown_field_tag(label = nil, options = nil, &block)
        #
        # Creates a <code><haptic-dropdown-field></code> tag wrapping the given field.
        #
        # ==== Options
        #
        # - <code>:animated_label</code> - If is set to <code>true</code>, the label is
        #   displayed as a placeholder if the value is empty and is moved to the top when
        #   the field is entered.
        # - <code>:error_message</code> - The error message.
        # - <code>:focus_indicator</code> - Specifies whether a focus indicator is shown:
        #   - <code>"focus"</code> or <code>true</code> - A focus indicator is shown
        #     when the field has been entered by keyboard or mouse.
        #   - <code>"focus-visible"</code> - A focus indicator is shown when the field
        #     has been entered by keyboard.
        # - <code>:leading_icon</code> - The name of the icon to be shown on the left side.
        # - <code>:set_valid_on_change</code> - The fields assumed not to be invalid when the
        #   value has been changed.
        # - <code>:show_error_icon</code> - If is set to <code>true</code>, an error icon is
        #   shown if the value is invalid.
        # - <code>:show_error_message</code> - If is set to <code>true</code>, the given error
        #   message is shown below the field.
        # - <code>:supporting_text</code> The helper text to be shown below the field.
        #
        # ==== Examples
        #
        #   haptic_dropdown_field_tag(haptic_select_dropdown_tag)
        #   # =>
        #   # <haptic-dropdown-field>
        #   #   <div class="field-container">
        #   #     <haptic-select-dropdown>
        #   #       <div class="backdrop"></div>
        #   #     </haptic-select-dropdown>
        #   #   </div>
        #   # </haptic-dropdown-field>
        #
        #   haptic_dropdown_field_tag(haptic_select_dropdown_tag, 'Label')
        #   # =>
        #   # <haptic-dropdown-field>
        #   #   <div class="field-container">
        #   #     <haptic-select-dropdown>
        #   #       <div class="backdrop"></div>
        #   #     </haptic-select-dropdown>
        #   #     <label class="field-label">Label</label>
        #   #   </div>
        #   # </haptic-dropdown-field>
        #
        #   haptic_dropdown_field_tag(
        #     haptic_select_dropdown_tag,
        #     'Label',
        #     animated_label: true,
        #     focus_indicator: true,
        #     error_message: 'Error message',
        #     leading_icon: 'leading_icon',
        #     show_error_icon: true,
        #     show_error_message: true,
        #     supporting_text: 'Helper text'
        #   )
        #   #=>
        #   # <haptic-dropdown-field animated-label focus-indicator="focus">
        #   #   <div class="field-container">
        #   #     <haptic-select-dropdown>
        #   #       <div class="backdrop"></div>
        #   #     </haptic-select-dropdown>
        #   #     <label class="field-label">Label</label>
        #   #     <div class="haptic-icon error-icon">error</div>
        #   #     <div class="haptic-icon leading-icon">leading_icon</div>
        #   #   </div>
        #   #   <div class="error-message">Error message</div>
        #   #   <div class="supporting-text">Helper text</div>
        #   # </haptic-dropdown-field>

        ##
        # :method: haptic_text_field_tag
        # :call-seq:
        #   haptic_text_field_tag(field = nil, label = nil, options = nil)
        #   haptic_text_field_tag(label = nil, options = nil, &block)
        #
        # Creates a <code><haptic-text-field></code> tag wrapping the given field.
        #
        # ==== Options
        #
        # - <code>:animated_label</code> - If is set to <code>true</code>, the label is
        #   displayed as a placeholder if the value is empty and is moved to the top when
        #   the field is entered.
        # - <code>:clear_button</code> - If is set to <code>true</code>, a clear button is
        #   provided.
        # - <code>:error_message</code> - The error message.
        # - <code>:focus_indicator</code> - Specifies whether a focus indicator is shown:
        #   - <code>"focus"</code> or <code>true</code> - A focus indicator is shown
        #     when the field has been entered by keyboard or mouse.
        #   - <code>"focus-visible"</code> - A focus indicator is shown when the field
        #     has been entered by keyboard.
        # - <code>:leading_icon</code> - The name of the icon to be shown on the left side.
        # - <code>:set_valid_on_change</code> - The fields assumed not to be invalid when the
        #   value has been changed.
        # - <code>:show_error_icon</code> - If is set to <code>true</code>, an error icon is
        #   shown if the value is invalid.
        # - <code>:show_error_message</code> - If is set to <code>true</code>, the given error
        #   message is shown below the field.
        # - <code>:supporting_text</code> The helper text to be shown below the field.
        # - <code>:trailing_icon</code> - The name of the icon to be shown on the right side.
        #
        # ==== Examples
        #
        #   haptic_text_field_tag(tag.input(type: 'text', name: 'name'))
        #   # =>
        #   # <haptic-text-field>
        #   #   <div class="field-container">
        #   #     <input type="text" name="name">
        #   #   </div>
        #   # </haptic-text-field>
        #
        #   haptic_text_field_tag(tag.input(type: 'text', name: 'name'), 'Label')
        #   # =>
        #   # <haptic-text-field>
        #   #   <div class="field-container">
        #   #     <input type="text" name="name">
        #   #     <label class="field-label">Label</label>
        #   #   </div>
        #   # </haptic-text-field>
        #
        #   haptic_text_field_tag(
        #     tag.input(type: 'text', name: 'name'),
        #     'Label',
        #     animated_label: true,
        #     clear_button: true,
        #     focus_indicator: true,
        #     error_message: 'Error message',
        #     leading_icon: 'leading_icon',
        #     show_error_icon: true,
        #     show_error_message: true,
        #     supporting_text: 'Helper text',
        #     trailing_icon: 'trailing_icon'
        #   )
        #   # =>
        #   # <haptic-text-field animated-label focus-indicator="focus">
        #   #   <div class="field-container">
        #   #     <input type="text" name="name">
        #   #     <label class="field-label">Label</label>
        #   #     <button type="button" class="clear-button">
        #   #       <div class="haptic-icon">close</div>
        #   #     </button>
        #   #     <div class="haptic-icon error-icon">error</div>
        #   #     <div class="haptic-icon leading-icon">leading_icon</div>
        #   #     <div class="haptic-icon trailing-icon">trailing_icon</div>
        #   #   </div>
        #   #   <div class="error-message">Error message</div>
        #   #   <div class="supporting-text">Helper text</div>
        #   # </haptic-text-field>

        %w[haptic-dropdown-field haptic-text-field].each do |tag_name|
          define_method(:"#{tag_name.underscore}_tag") do |field = nil, label = nil, options = nil, &block|
            field, label, options = capture(&block), field, label if block
            field, label, options = '', nil, field if field.is_a?(Hash)
            label, options = nil, label if label.is_a?(Hash)
            field = (field || '').html_safe unless field&.html_safe?

            options = options&.transform_keys { |key| key.to_s.dasherize } || {}

            clear_button = options.delete('clear-button')
            error_message = options.delete('error-message')
            leading_icon = options.delete('leading-icon')
            show_error_icon = options.delete('show-error-icon')
            show_error_message = options.delete('show-error-message')
            supporting_text = options.delete('supporting-text')
            trailing_icon = options.delete('trailing-icon')

            content_tag(
              tag_name,
              content_tag(
                'div',
                field +
                  if label
                    label.html_safe? ? label : content_tag('label', label, class: 'field-label')
                  end +
                  if tag_name == 'haptic-text-field' && clear_button
                    content_tag('button', haptic_icon_tag('close'), type: 'button', class: 'clear-button')
                  end +
                  if show_error_icon
                    haptic_icon_tag('error', class: 'error-icon')
                  end +
                  if leading_icon
                    haptic_icon_tag(leading_icon, class: 'leading-icon')
                  end +
                  if tag_name == 'haptic-text-field' && trailing_icon
                    haptic_icon_tag(trailing_icon, class: 'trailing-icon')
                  end,
                class: 'field-container'
              ) +
                if show_error_message && error_message.present?
                  content_tag('div', error_message, class: 'error-message')
                end +
                if supporting_text
                  content_tag('div', supporting_text, class: 'supporting-text')
                end,
              options.filter_map do |key, value|
                [
                  key,
                  case value
                  when false
                    nil
                  when true
                    key == 'focus-indicator' ? 'focus' : ''
                  else
                    value
                  end
                ]
              end.to_h
            )
          end
        end
      end
    end
  end
end
