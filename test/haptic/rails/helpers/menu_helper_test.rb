# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class MenuHelperTest < ActionView::TestCase
        include MenuHelper
        include TagHelper

        def test_haptic_dropdown_menu_with_block
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-menu>
                <haptic-menu class="popover">
                  <a is="haptic-menu-item" href="/">Home</a>
                </haptic-menu>
                <div class="backdrop"></div>
              </haptic-dropdown-menu>
            HTML
            haptic_dropdown_menu do |dropdown|
              dropdown.menu do |menu|
                menu.item 'Home', href: '/'
              end
            end
          )
        end

        def test_haptic_dropdown_menu_without_block
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-menu>
                <div class="backdrop"></div>
              </haptic-dropdown-menu>
            HTML
            haptic_dropdown_menu
          )
        end
      end
    end
  end
end
