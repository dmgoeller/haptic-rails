# frozen_string_literal: true

require_relative 'icon_helper'

module Haptic
  module Rails
    module Helpers
      module FormHelper
        # Creates an asynchronously submitted form with a checkbox.
        #
        # ==== Options
        #
        # - <code>:form</code> - The options to be applied to the form.
        #
        # Other options are passed to the checkbox. Note that <code>:onchange</code> is
        # overwritten to submit the form when then checkbox has been checked or unchecked.
        #
        # ==== Example
        #
        #   haptic_async_checkbox dummy, :accepted
        #   # =>
        #   # <form is="haptic-async-form" action="/dummies/1" method="post">
        #   #   <input type="hidden" name="_method" value="patch" />
        #   #   <input type="hidden" name="authenticity_token" value="..." />
        #   #   <input type="hidden" name="dummy[accepted]" value="0" />
        #   #   <input type="checkbox" is="haptic-input" class="async"
        #   #     id="dummy_accepted" name="dummy[accepted]" value="1"
        #   #     onchange="this.form.requestSubmit()" />
        #   # </form>
        def haptic_async_checkbox_for(record, method, options = {}, checked_value = '1', unchecked_value = '0')
          haptic_async_form_for(record, options.delete(:form) || {}) do |form|
            options = options.merge(
              class: [options[:class], 'async'],
              onchange: 'this.form.requestSubmit()'
            )
            form.check_box(method, options, checked_value, unchecked_value)
          end
        end

        # Creates an asynchronously submitted form.
        def haptic_async_form_for(record, options = {}, &block)
          html_options = options[:html] || {}
          html_options[:is] = 'haptic-async-form'

          options = options.merge(
            builder: Haptic::Rails::FormBuilder,
            html: html_options
          )
          form_for(record, options, &block)
        end

        # Creates a form.
        def haptic_form_for(record, options = {}, &block)
          html_options = options[:html] || {}
          html_options[:is] = 'haptic-form'

          options = options.merge(
            builder: Haptic::Rails::FormBuilder,
            html: html_options
          )
          form_for(record, options, &block)
        end
      end
    end
  end
end
