# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class DropdownBuilderTest < ActionView::TestCase
      def test_toggle
        assert_dom_equal(
          <<~HTML,
            <button type="button" class="toggle"></button>
          HTML
          dropdown_builder.toggle
        )
      end

      def test_toggle_with_options
        assert_dom_equal(
          <<~HTML,
            <button type="button" class="toggle foo-class" data-foo="bar"></button>
          HTML
          dropdown_builder.toggle(class: 'foo-class', data: { foo: 'bar' })
        )
      end

      def test_toggle_with_content
        assert_dom_equal(
          <<~HTML,
            <button type="button" class="toggle">Text</button>
          HTML
          dropdown_builder.toggle('Text')
        )
      end

      def test_toggle_with_content_and_options
        assert_dom_equal(
          <<~HTML,
            <button type="button" class="toggle foo-class" data-foo="bar">Text</button>
          HTML
          dropdown_builder.toggle('Text', class: 'foo-class', data: { foo: 'bar' })
        )
      end

      def test_toggle_with_block
        assert_dom_equal(
          <<~HTML,
            <button type="button" class="toggle"> Text</button>
          HTML
          dropdown_builder.toggle { 'Text' }
        )
      end

      def test_toggle_with_block_and_options
        assert_dom_equal(
          <<~HTML,
            <button type="button" class="toggle foo-class" data-foo="bar">Text</button>
          HTML
          dropdown_builder.toggle(class: 'foo-class', data: { foo: 'bar' }) { 'Text' }
        )
      end

      def test_toggle_with_defaults
        assert_dom_equal(
          <<~HTML,
            <button type="button" class="toggle foo-class bar-class">
              Text
            </button>
          HTML
          dropdown_builder(class: 'foo-class').toggle('Text', class: 'bar-class')
        )
      end

      private

      def dropdown_builder(**options)
        DropdownBuilder.new(self, options)
      end
    end
  end
end
