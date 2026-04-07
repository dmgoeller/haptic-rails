# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class DropdownDialogBuilderTest < ActionView::TestCase
      def test_popover
        assert_dom_equal(
          <<~HTML,
            <div class="popover"></div>
          HTML
          dropdown_dialog_builder.popover
        )
      end

      def test_popover_with_options
        assert_dom_equal(
          <<~HTML,
            <div class="popover foo-class" data-foo="bar"></div>
          HTML
          dropdown_dialog_builder.popover(
            class: 'foo-class',
            data: { foo: 'bar' }
          )
        )
      end

      def test_popover_with_content
        assert_dom_equal(
          <<~HTML,
            <div class="popover">Content</div>
          HTML
          dropdown_dialog_builder.popover('Content')
        )
      end

      def test_popover_with_content_and_options
        assert_dom_equal(
          <<~HTML,
            <div class="popover foo-class" data-foo="bar">Content</div>
          HTML
          dropdown_dialog_builder.popover(
            'Content',
            class: 'foo-class',
            data: { foo: 'bar' }
          )
        )
      end

      def test_popover_with_block
        assert_dom_equal(
          <<~HTML,
            <div class="popover">Content</div>
          HTML
          dropdown_dialog_builder.popover { 'Content' }
        )
      end

      def test_popover_with_block_and_options
        assert_dom_equal(
          <<~HTML,
            <div class="popover foo-class" data-foo="bar">Content</div>
          HTML
          dropdown_dialog_builder.popover(
            class: 'foo-class',
            data: { foo: 'bar' }
          ) do
            'Content'
          end
        )
      end

      private

      def dropdown_dialog_builder(**options)
        DropdownDialogBuilder.new(self, options)
      end
    end
  end
end
