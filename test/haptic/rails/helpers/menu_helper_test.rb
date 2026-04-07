# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class MenuHelperTest < ActionView::TestCase
        include DropdownTagHelper
        include MenuHelper

        def test_haptic_dropdown_menu
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-menu>
                <div class="backdrop"></div>
              </haptic-dropdown-menu>
            HTML
            haptic_dropdown_menu
          )
        end

        def test_haptic_dropdown_menu_with_options
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-menu open-to-top>
                <div class="backdrop"></div>
              </haptic-dropdown-menu>
            HTML
            haptic_dropdown_menu(open_to_top: true)
          )
        end

        def test_haptic_dropdown_menu_with_block
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-menu>
                <haptic-menu class="popover">
                  <a is="haptic-menu-item" href="/duplicate">Duplicate</a>
                </haptic-menu>
                <div class="backdrop"></div>
              </haptic-dropdown-menu>
            HTML
            haptic_dropdown_menu do |dropdown|
              dropdown.menu do |menu|
                menu.item 'Duplicate', href: '/duplicate'
              end
            end
          )
        end

        def test_haptic_dropdown_menu_with_block_and_options
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-menu open-to-top>
                <haptic-menu class="popover">
                  <a is="haptic-menu-item" href="/duplicate">Duplicate</a>
                </haptic-menu>
                <div class="backdrop"></div>
              </haptic-dropdown-menu>
            HTML
            haptic_dropdown_menu(open_to_top: true) do |dropdown|
              dropdown.menu do |menu|
                menu.item 'Duplicate', href: '/duplicate'
              end
            end
          )
        end
      end
    end
  end
end
