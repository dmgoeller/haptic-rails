# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class MenuBuilderTest < ActionView::TestCase
      # #divider

      def test_divider
        assert_dom_equal(
          <<~HTML,
            <div class="divider"></div>
          HTML
          menu_builder.divider
        )
      end

      # #item

      def test_item
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-menu-item" href="/">
              Home
            </a>
          HTML
          menu_builder.item('Home', href: '/')
        )
      end

      def test_item_with_block
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-menu-item" href="/">
              Home
            </a>
          HTML
          menu_builder.item(href: '/') { 'Home' }
        )
      end

      def test_item_with_defaults
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-menu-item" href="/" rel="next">
              Home
            </a>
          HTML
          menu_builder(rel: 'next').item(href: '/') { 'Home' }
        )
      end

      # #item_to

      def test_item_to
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-menu-item" href="/">
              Home
            </a>
          HTML
          menu_builder.item_to('Home', '/')
        )
      end

      def test_item_to_with_block
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-menu-item" href="/">
              Home
            </a>
          HTML
          menu_builder.item_to('/') { 'Home' }
        )
      end

      def test_item_to_with_defaults
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-menu-item" href="/" rel="next">
              Home
            </a>
          HTML
          menu_builder(rel: 'next').item_to('/') { 'Home' }
        )
      end

      private

      def menu_builder(options = {})
        MenuBuilder.new(self, options)
      end
    end
  end
end
