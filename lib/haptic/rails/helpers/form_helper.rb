# frozen_string_literal: true

require_relative 'icon_helper'

module Haptic
  module Rails
    module Helpers
      module FormHelper
        # Creates a form that is submitted asynchronously.
        #
        # ==== Options
        #
        # - <code>:request_submit_on_change</code>
        def haptic_async_form_for(record, options = {}, &block)
          html_options = options[:html] || {}
          html_options[:is] = 'haptic-async-form'

          options = options.merge(html: html_options)

          haptic_form_for(record, options, &block)
        end

        # Creates a form.
        #
        # ==== Options
        #
        # - <code>:request_submit_on_change</code>
        def haptic_form_for(record, options = {}, &block)
          html_options = options[:html] || {}
          html_options[:is] ||= 'haptic-form'

          if options.delete(:request_submit_on_change)
            html_options[:'request-submit-on-change'] = ''
          end

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
