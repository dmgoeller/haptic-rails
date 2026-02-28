# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class UrlHelperTest < ActionView::TestCase
        include UrlHelper

        def test_haptic_nav_item_to
          assert_dom_equal(
            <<~HTML,
              <a is="haptic-nav-item" href="/" rel="next" active-on="_pathname">
                Home
              </a>
            HTML
            haptic_nav_item_to('Home', '/')
          )
        end

        def test_haptic_nav_item_to_with_block
          assert_dom_equal(
            <<~HTML,
              <a is="haptic-nav-item" href="/" rel="next" active-on="_pathname">
                Home
              </a>
            HTML
            haptic_nav_item_to('/') { 'Home' }
          )
        end
      end
    end
  end
end
