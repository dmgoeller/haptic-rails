# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module IconHelper
        def haptic_icon_tag(name, options = {})
          options = options.merge(
            builder: self,
            class: ['haptic-icon', options[:class]].flatten
          )
          Haptic::Rails.configuration.icon_builder&.call(name, options)
        end
      end
    end
  end
end
