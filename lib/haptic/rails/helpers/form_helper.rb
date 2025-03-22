# frozen_string_literal: true

require_relative 'icon_helper'

module Haptic
  module Rails
    module Helpers
      module FormHelper
        def haptic_async_checkbox_for(record, method, options = {}, checked_value = '1', unchecked_value = '0')
          haptic_async_form_for(record, options.delete(:form) || {}) do |form|
            options = options.merge(
              class: [options[:class], 'async', 'embedded'],
              onchange: 'this.form.requestSubmit()'
            )
            form.check_box(method, options, checked_value, unchecked_value)
          end
        end

        def haptic_async_form_for(record, options = {}, &block)
          html_options = options[:html] || {}
          html_options[:is] = 'haptic-async-form'

          form_for(record, options.merge(html: html_options), &block)
        end
      end
    end
  end
end
