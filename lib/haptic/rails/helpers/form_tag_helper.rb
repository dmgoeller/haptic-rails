# frozen_string_literal: true

require_relative 'css_helper'

module Haptic
  module Rails
    module Helpers
      module FormTagHelper
        def haptic_checkbox(name, value = '1', checked = false, options = {})
          check_box_tag(name, value, checked, options.merge(is: 'haptic-input'))
        end

        def haptic_radio_button(name, value, checked = false, options = {})
          radio_button_tag(name, value, checked, options.merge(is: 'haptic-input'))
        end

        def haptic_switch(name, value = '1', checked = false, options = {})
          options = options.merge(class: haptic_css_class(options[:class], 'haptic-switch'))
          haptic_checkbox(name, value, checked, options)
        end
      end
    end
  end
end
