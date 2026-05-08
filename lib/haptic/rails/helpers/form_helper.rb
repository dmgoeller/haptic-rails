# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module FormHelper
        ##
        # :call-seq: haptic_async_form_for(**options, &block)
        #
        # Creates a form that is submitted asynchronously.
        #
        # ==== Options
        #
        # - <code>:accept</code> - The content type a response must match. The default content
        #   type is <code>'application/json'</code>.
        # - <code>:redirect</code> - Specifies the mode how redirects are handled. Can be
        #   <code>'follow'</code>, <code>'error'</code> or <code>'manual'</code>. The default
        #   mode is <code>'follow'</code>.
        # - <code>:submit_on_change</code> - If is set to <code>true</code>, the form is
        #   submitted when a field value has been changed.
        def haptic_async_form_for(record, html: {}, **options, &block)
          options = options.dup

          html = html.reverse_merge(is: 'haptic-async-form')
          html[:'data-accept'] ||= options.delete(:accept)
          html[:'data-redirect'] ||= options.delete(:redirect)

          haptic_form_for(record, html: html, **options, &block)
        end

        ##
        # :call-seq: haptic_async_form_with(**options, &block)
        #
        # Creates a form that is submitted asynchronously.
        #
        # ==== Options
        #
        # - <code>:accept</code> - The content type a response must match. The default content
        #   type is <code>'application/json'</code>.
        # - <code>:redirect</code> - Specifies the mode how redirects are handled. Can be
        #   <code>'follow'</code>, <code>'error'</code> or <code>'manual'</code>. The default
        #   mode is <code>'follow'</code>.
        # - <code>:submit_on_change</code> - If is set to <code>true</code>, the form is
        #   submitted when a field value has been changed.
        def haptic_async_form_with(data: {}, html: {}, **options, &block)
          options = options.dup
          data = data.reverse_merge(options.extract!(:accept, :redirect))
          html = html.reverse_merge(is: 'haptic-async-form')

          haptic_form_with(data: data, html: html, **options, &block)
        end

        # Creates a form.
        #
        # ==== Options
        #
        # - <code>:submit_on_change</code> - If is set to <code>true</code>, the form is
        #   submitted when a field value has been changed.
        def haptic_form_for(record, html: {}, **options, &block)
          options = options.reverse_merge(builder: Haptic::Rails::FormBuilder)

          html = html.reverse_merge(is: 'haptic-form')
          html[:'data-submit-on-change'] ||= '' if options.delete(:submit_on_change)

          form_for(record, options.merge(html: html), &block)
        end

        ##
        # :call-seq: haptic_form_with(**options, &block)
        #
        # Creates a form.
        #
        # ==== Options
        #
        # - <code>:submit_on_change</code> - If is set to <code>true</code>, the form is
        #   submitted when a field value has been changed.
        def haptic_form_with(data: {}, html: {}, **options, &block)
          options = options.reverse_merge(builder: Haptic::Rails::FormBuilder)
          submit_on_change = options.delete(:submit_on_change)

          data = { 'submit-on-change': '' }.merge(data) if submit_on_change
          html = { is: 'haptic-form' }.merge(html)

          form_with(data: data.presence, html: html, **options, &block)
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
