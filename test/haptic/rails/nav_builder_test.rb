# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class NavBuilderTest < ActionView::TestCase
      def test_item
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-nav-item" href="/" active-on="_pathname">
              Home
            </a>
          HTML
          nav_builder.item('Home', '/')
        )
      end

      def test_item_with_block
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-nav-item" href="/" active-on="_pathname">
              Home
            </a>
          HTML
          nav_builder.item('/') { 'Home' }
        )
      end

      def test_item_with_default_options
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-nav-item" href="/" rel="next" active-on="_pathname">
              Home
            </a>
          HTML
          nav_builder(defaults: { rel: 'next' }).item('Home', '/')
        )
      end

      def test_section
        assert_dom_equal(
          <<~HTML,
            <div class="nav-section">
              <div>Content</div>
            </div>
          HTML
          nav_builder.section { content_tag('div', 'Content') }
        )
      end

      def test_section_with_label
        assert_dom_equal(
          <<~HTML,
            <div class="nav-section">
              <div class="nav-section-label">Label</div>
              <div>Content</div>
            </div>
          HTML
          nav_builder.section('Label') { content_tag('div', 'Content') }
        )
      end

      private

      def nav_builder(options = {})
        NavBuilder.new(self, options)
      end
    end
  end
end
