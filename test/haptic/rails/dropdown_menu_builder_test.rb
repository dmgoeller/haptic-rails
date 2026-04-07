# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class DropdownMenuBuilderTest < ActionView::TestCase
      include Helpers::DropdownTagHelper

      # #toggle

      def test_toggle
        assert_dom_equal(
          <<~HTML,
            <button is="haptic-button" type="button" class="toggle">
              Text
            </button>
          HTML
          dropdown_menu_builder.toggle('Text')
        )
      end

      def test_toggle_with_block
        assert_dom_equal(
          <<~HTML,
            <button is="haptic-button" type="button" class="toggle">Text</button>
          HTML
          dropdown_menu_builder.toggle { 'Text' }
        )
      end

      def test_toggle_with_class
        assert_dom_equal(
          <<~HTML,
            <button is="haptic-button" type="button" class="toggle foo">
              Text
            </button>
          HTML
          dropdown_menu_builder.toggle('Text', class: 'foo')
        )
      end

      def test_toggle_with_options
        assert_dom_equal(
          <<~HTML,
            <button is="haptic-button" type="button" class="toggle" disabled="disabled">
              Text
            </button>
          HTML
          dropdown_menu_builder.toggle('Text', disabled: true)
        )
      end

      # #menu

      def test_menu
        assert_dom_equal(
          <<~HTML,
            <haptic-menu class="popover"></haptic-menu>
          HTML
          dropdown_menu_builder.menu
        )
      end

      def test_menu_with_custom_class
        assert_dom_equal(
          <<~HTML,
            <haptic-menu class="popover custom"></haptic-menu>
          HTML
          dropdown_menu_builder.menu(class: 'custom')
        )
      end

      def test_menu_with_block
        assert_dom_equal(
          <<~HTML,
            <haptic-menu class="popover">
              <a is="haptic-menu-item" href="/duplicate">Duplicate</a>
            </haptic-menu>
          HTML
          dropdown_menu_builder.menu { |menu| menu.item('Duplicate', href: '/duplicate') }
        )
      end

      def test_menu_with_defaults
        assert_dom_equal(
          <<~HTML,
            <haptic-menu class="popover">
              <a is="haptic-menu-item" href="/duplicate" rel="next">Duplicate</a>
            </haptic-menu>
          HTML
          dropdown_menu_builder.menu(defaults: { rel: 'next' }) do |menu|
            menu.item('Duplicate', href: '/duplicate')
          end
        )
      end

      private

      def dropdown_menu_builder
        DropdownMenuBuilder.new(self)
      end
    end
  end
end
