# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class MenuBuilderTest < ActionView::TestCase
      include Helpers::IconHelper

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
            <a is="haptic-menu-item" href="/duplicate">
              Duplicate
            </a>
          HTML
          menu_builder.item('Duplicate', href: '/duplicate')
        )
      end

      def test_item_with_block
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-menu-item" href="/duplicate">
              Duplicate
            </a>
          HTML
          menu_builder.item(href: '/duplicate') { 'Duplicate' }
        )
      end

      def test_item_with_leading_icon
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-menu-item" href="/duplicate">
              Duplicate
              <div class="haptic-icon leading-icon">copy</div>
            </a>
          HTML
          menu_builder.item('Duplicate', href: '/duplicate', leading_icon: 'copy')
        )
      end

      def test_item_with_leading_icon_and_block
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-menu-item" href="/duplicate">
              Duplicate
              <div class="haptic-icon leading-icon">copy</div>
            </a>
          HTML
          menu_builder.item(href: '/duplicate', leading_icon: 'copy') { 'Duplicate' }
        )
      end

      def test_item_with_defaults
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-menu-item" href="/duplicate" rel="next">
              Duplicate
            </a>
          HTML
          menu_builder(rel: 'next').item(href: '/duplicate') { 'Duplicate' }
        )
      end

      # #item_to

      def test_item_to
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-menu-item" href="/duplicate">
              Duplicate
            </a>
          HTML
          menu_builder.item_to('Duplicate', '/duplicate')
        )
      end

      def test_item_to_with_block
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-menu-item" href="/duplicate">
              Duplicate
            </a>
          HTML
          menu_builder.item_to('/duplicate') { 'Duplicate' }
        )
      end

      def test_item_to_with_leading_icon
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-menu-item" href="/duplicate">
              Duplicate
              <div class="haptic-icon leading-icon">copy</div>
            </a>
          HTML
          menu_builder.item_to('Duplicate', '/duplicate', leading_icon: 'copy')
        )
      end

      def test_item_to_with_leading_icon_and_block
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-menu-item" href="/duplicate">
              Duplicate
              <div class="haptic-icon leading-icon">copy</div>
            </a>
          HTML
          menu_builder.item_to('/duplicate', leading_icon: 'copy') { 'Duplicate' }
        )
      end

      def test_item_to_with_defaults
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-menu-item" href="/duplicate" rel="next">
              Duplicate
            </a>
          HTML
          menu_builder(rel: 'next').item_to('/duplicate') { 'Duplicate' }
        )
      end

      private

      def menu_builder(options = {})
        MenuBuilder.new(self, options)
      end
    end
  end
end
