# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class ConfigurationTest < ActionView::TestCase
      def test_default_icon_builder
        icon_builder = Haptic::Rails.configuration.icon_builder

        assert_dom_equal(
          <<~HTML,
            <div>close</div>
          HTML
          icon_builder.call('close', builder: self)
        )
        assert_dom_equal(
          <<~HTML,
            <div>calendar_today</div>
          HTML
          icon_builder.call('calendar', builder: self)
        )
      end
    end
  end
end
