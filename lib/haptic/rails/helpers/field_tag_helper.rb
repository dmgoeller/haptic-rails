# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module FieldTagHelper
        ##
        # :method: haptic_dropdown_field_tag
        # :call-seq:
        #   haptic_dropdown_field_tag(field = nil, label = nil, **options)
        #   haptic_dropdown_field_tag(label = nil, **options, &block)
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
        #   haptic_text_field_tag(field = nil, label = nil, **options)
        #   haptic_text_field_tag(label = nil, **options, &block)
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
          define_method(:"#{tag_name.underscore}_tag") do |field = nil, label = nil, **options, &block|
            field, label = capture(&block), field if block
            field = (field || '').html_safe unless field&.html_safe?

            clear_button = options.delete(:clear_button)
            error_message = options.delete(:error_message)
            leading_icon = options.delete(:leading_icon)
            show_error_icon = options.delete(:show_error_icon)
            show_error_message = options.delete(:show_error_message)
            supporting_text = options.delete(:supporting_text)
            trailing_icon = options.delete(:trailing_icon)

            tag.send(
              tag_name,
              tag.div(
                field +
                  if label
                    label.html_safe? ? label : tag.label(label, class: 'field-label')
                  end +
                  if tag_name == 'haptic-text-field' && clear_button
                    tag.button(haptic_icon_tag('close'), type: 'button', class: 'clear-button')
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
                  tag.div(error_message, class: 'error-message')
                end +
                if supporting_text
                  tag.div(supporting_text, class: 'supporting-text')
                end,
              **options.filter_map do |key, value|
                [
                  key.to_s.dasherize.to_sym,
                  case value
                  when false
                    nil
                  when true
                    key == :focus_indicator ? 'focus' : ''
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
