# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class NavBuilderTest < ActionView::TestCase
      include Helpers::IconTagHelper

      # #item

      def test_item
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-nav-item" href="/" active-on="_pathname"></a>
          HTML
          nav_builder.item(href: '/')
        )
      end

      def test_item_with_name
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-nav-item" href="/" active-on="_pathname">Home</a>
          HTML
          nav_builder.item('Home', href: '/')
        )
      end

      def test_item_with_name_and_leading_icon
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-nav-item" href="/" active-on="_pathname">
              Home
              <div class="haptic-icon leading-icon">home</div>
            </a>
          HTML
          nav_builder.item('Home', href: '/', leading_icon: 'home')
        )
      end

      def test_item_with_block
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-nav-item" href="/" active-on="_pathname">Home</a>
          HTML
          nav_builder.item(href: '/') { 'Home' }
        )
      end

      def test_item_with_block_and_leading_icon
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-nav-item" href="/" active-on="_pathname">
              Home
              <div class="haptic-icon leading-icon">home</div>
            </a>
          HTML
          nav_builder.item(href: '/', leading_icon: 'home') { 'Home' }
        )
      end

      def test_item_with_defaults
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-nav-item" href="/" rel="next" active-on="_pathname">Home</a>
          HTML
          nav_builder(rel: 'next').item('Home', href: '/')
        )
      end

      # #item_to

      def test_item_to_with_name
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-nav-item" href="/" active-on="_pathname">Home</a>
          HTML
          nav_builder.item_to('Home', '/')
        )
      end

      def test_item_to_with_name_and_leading_icon
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-nav-item" href="/" active-on="_pathname">
              Home
              <div class="haptic-icon leading-icon">home</div>
            </a>
          HTML
          nav_builder.item_to('Home', '/', leading_icon: 'home')
        )
      end

      def test_item_to_with_block
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-nav-item" href="/" active-on="_pathname">Home</a>
          HTML
          nav_builder.item_to('/') { 'Home' }
        )
      end

      def test_item_to_with_leading_icon_and_block
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-nav-item" href="/" active-on="_pathname">
              Home
              <div class="haptic-icon leading-icon">home</div>
            </a>
          HTML
          nav_builder.item_to('/', leading_icon: 'home') { 'Home' }
        )
      end

      def test_item_to_with_defaults
        assert_dom_equal(
          <<~HTML,
            <a is="haptic-nav-item" href="/" rel="next" active-on="_pathname">Home</a>
          HTML
          nav_builder(rel: 'next').item_to('Home', '/')
        )
      end

      # #section

      def test_section
        assert_dom_equal(
          <<~HTML,
            <div class="nav-section"></div>
          HTML
          nav_builder.section
        )
      end

      def test_section_with_options
        assert_dom_equal(
          <<~HTML,
            <div class="nav-section foo-class" data-foo="bar"></div>
          HTML
          nav_builder.section(class: 'foo-class', data: { foo: 'bar' })
        )
      end

      def test_section_with_label
        assert_dom_equal(
          <<~HTML,
            <div class="nav-section">
              <div class="nav-section-label">Label</div>
            </div>
          HTML
          nav_builder.section('Label')
        )
      end

      def test_section_with_label_and_options
        assert_dom_equal(
          <<~HTML,
            <div class="nav-section foo-class" data-foo="bar">
              <div class="nav-section-label">Label</div>
            </div>
          HTML
          nav_builder.section('Label', class: 'foo-class', data: { foo: 'bar' })
        )
      end

      def test_section_with_block
        assert_dom_equal(
          <<~HTML,
            <div class="nav-section">
              <a is="haptic-nav-item" href="/" active-on="_pathname">Home</a>
            </div>
          HTML
          nav_builder.section { nav_builder.item('Home', href: '/') }
        )
      end

      def test_section_with_block_and_options
        assert_dom_equal(
          <<~HTML,
            <div class="nav-section foo-class" data-foo="bar">
              <a is="haptic-nav-item" href="/" active-on="_pathname">Home</a>
            </div>
          HTML
          nav_builder.section(class: 'foo-class', data: { foo: 'bar' }) do
            nav_builder.item('Home', href: '/')
          end
        )
      end

      def test_section_with_block_and_label
        assert_dom_equal(
          <<~HTML,
            <div class="nav-section">
              <div class="nav-section-label">Label</div>
              <a is="haptic-nav-item" href="/" active-on="_pathname">Home</a>
            </div>
          HTML
          nav_builder.section('Label') { nav_builder.item('Home', href: '/') }
        )
      end

      def test_section_with_block_label_and_options
        assert_dom_equal(
          <<~HTML,
            <div class="nav-section foo-class" data-foo="bar">
              <div class="nav-section-label">Label</div>
              <a is="haptic-nav-item" href="/" active-on="_pathname">Home</a>
            </div>
          HTML
          nav_builder.section('Label', class: 'foo-class', data: { foo: 'bar' }) do
            nav_builder.item('Home', href: '/')
          end
        )
      end

      private

      def nav_builder(**options)
        NavBuilder.new(self, **options)
      end
    end
  end
end
