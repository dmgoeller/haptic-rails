# frozen_string_literal: true

require_relative 'icon_helper'

module Haptic
  module Rails
    module Helpers
      module FormHelper
        # Creates a form that is submitted asynchronously.
        def haptic_async_form_for(record, options = {}, &block)
          html_options = options[:html] || {}
          html_options[:is] = 'haptic-async-form'

          options = options.merge(html: html_options)

          haptic_form_for(record, options, &block)
        end

        # Creates a form.
        def haptic_form_for(record, options = {}, &block)
          html_options = options[:html] || {}
          html_options[:is] ||= 'haptic-form'

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
