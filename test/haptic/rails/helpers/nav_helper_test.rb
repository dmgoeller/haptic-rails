# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class NavHelperTest < ActionView::TestCase
        include NavHelper

        def test_haptiv_nav
          assert_dom_equal(
            <<~HTML,
              <nav is="haptic-nav">
                <a is="haptic-nav-item" href="/" active-on="_pathname">Home</a>
              </nav>
            HTML
            haptic_nav do |nav|
              nav.item 'Home', '/'
            end
          )
        end

        def test_haptiv_nav_with_defaults
          assert_dom_equal(
            <<~HTML,
              <nav is="haptic-nav">
                <a is="haptic-nav-item" href="/" active-on="_pathname" rel="next">Home</a>
              </nav>
            HTML
            haptic_nav(defaults: { rel: 'next' }) do |nav|
              nav.item 'Home', '/'
            end
          )
        end

        def test_haptic_nav_without_block
          assert_dom_equal(
            <<~HTML,
              <nav is="haptic-nav"></nav>
            HTML
            haptic_nav
          )
        end
      end
    end
  end
end
