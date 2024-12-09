# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module FormTagHelper
        def haptic_checkbox(name, value = '1', checked = false, options = {})
          check_box_tag(name, value, checked, options.merge(is: 'haptic-input'))
        end

        def haptic_label(name = nil, content_or_options = nil, options = nil, &block)
          content_or_options = content_options.merge(is: 'haptic-label') if content_or_options.is_a?(Hash)
          options = options.merge(is: 'haptic-label') if options.is_a?(Hash)
          label_tag(name, content_or_options, options, &block)
        end

        def haptic_radio_button(name, value, checked = false, options = {})
          radio_button_tag(name, value, checked, options.merge(is: 'haptic-input'))
        end

        def haptic_switch(name, value = '1', checked = false, options = {})
          options = options.merge(class: [options[:class], 'haptic-switch'].flatten)
          haptic_checkbox(name, value, checked, options)
        end
      end
    end
  end
end
