# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module CSSHelper
        def haptic_css_class(*css_classes)
          css_classes.filter_map { |c| c&.split(' ') }.flatten.uniq.join(' ')
        end
      end
    end
  end
end
