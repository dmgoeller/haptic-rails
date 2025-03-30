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
        # - <code>:accept</code> - The content type a response must match. The default content
        #   type is <code>'application/json'</code>.
        # - <code>:redirect</code> - Specifies the mode how redirects are handled. Can be
        #   <code>'follow'</code>, <code>'error'</code> or <code>'manual'</code>. The default
        #   mode is <code>'follow'</code>.
        # - <code>:submit_on_change</code> - If <code>true</code>, the form is submitted when
        #   a field value has been changed.
        #
        # ==== Example
        #
        #   haptic_async_form_for :dummy do |f|
        #     # ...
        #   end
        def haptic_async_form_for(record, options = {}, &block)
          html_options = options[:html] || {}
          html_options[:is] ||= 'haptic-async-form'
          html_options[:'data-accept'] ||= options.delete(:accept)
          html_options[:'data-redirect'] ||= options.delete(:redirect)
          html_options[:'data-submit-on-change'] ||= '' if options.delete(:submit_on_change)

          haptic_form_for(record, options.merge(html: html_options), &block)
        end

        # Creates a form.
        #
        # ==== Example
        #
        #   haptic_form_for :dummy do |f|
        #     # ...
        #   end
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
