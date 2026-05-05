# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module FormHelper
        # Creates a form that is submitted asynchronously.
        #
        # ==== Options
        #
        # - <code>:accept</code> - The content type a response must match. The default content
        #   type is <code>'application/json'</code>.
        # - <code>:redirect</code> - Specifies the mode how redirects are handled. Can be
        #   <code>'follow'</code>, <code>'error'</code> or <code>'manual'</code>. The default
        #   mode is <code>'follow'</code>.
        # - <code>:submit_on_change</code> - If <code>true</code>, the form is submitted when
        #   a field value has been changed.
        def haptic_async_form_for(record, options = {}, &block)
          options = options.symbolize_keys
          options[:builder] = Haptic::Rails::FormBuilder

          html_options = options[:html] || {}
          html_options[:is] ||= 'haptic-async-form'
          html_options[:'data-accept'] ||= options.delete(:accept)
          html_options[:'data-redirect'] ||= options.delete(:redirect)
          html_options[:'data-submit-on-change'] ||= '' if options.delete(:submit_on_change)
          options[:html] = html_options

          form_for(record, options, &block)
        end

        # Creates a form.
        def haptic_form_for(record, options = {}, &block)
          options = options.symbolize_keys
          options[:builder] = Haptic::Rails::FormBuilder

          html_options = options[:html] || {}
          html_options[:is] ||= 'haptic-form'
          options[:html] = html_options

          form_for(record, options, &block)
        end

        def haptic_select_dropdown(object_name, method, haptic_options, options = {})
          options = options.symbolize_keys
          field_options = options.extract!(:disabled, :id, :required)
          toggle_class = ['toggle', 'haptic-field', options.delete(:class)]

          haptic_select_dropdown_tag(
            text_field(object_name, method, field_options) +
              tag.button(type: 'button', class: toggle_class) +
              tag.div(
                tag.div(haptic_options, class: 'scroll-container'),
                class: 'popover'
              ),
            **options
          )
        end
      end
    end
  end
end
