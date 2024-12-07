# frozen_string_literal: true

require_relative 'css_helper'

module Haptic
  module Rails
    module Helpers
      module IconHelper
        include CSSHelper

        def haptic_icon(name, options = {})
          options = options.merge(
            builder: self,
            class: haptic_css_class(options[:class], 'haptic-icon')
          )
          Haptic::Rails.configuration.icon_builder&.call(name, options)
        end
      end
    end
  end
end
