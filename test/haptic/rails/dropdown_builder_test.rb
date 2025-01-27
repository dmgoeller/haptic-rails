# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class DropdownBuilderTest < ActionView::TestCase
      # #toggle

      def test_toggle
        assert_dom_equal(
          <<~HTML,
            <button type="button" class="toggle">
              Text
            </button>
          HTML
          dropdown_builder.toggle('Text')
        )
      end

      def test_toggle_with_classes
        assert_dom_equal(
          <<~HTML,
            <button type="button" class="toggle foo bar">
              Text
            </button>
          HTML
          dropdown_builder(class: 'foo').toggle('Text', class: 'bar')
        )
      end

      def test_toggle_with_block
        assert_dom_equal(
          <<~HTML,
            <button type="button" class="toggle">
              <div>Text</div>
            </button>
          HTML
          dropdown_builder.toggle { content_tag('div', 'Text') }
        )
      end

      def test_toggle_with_class_and_block
        assert_dom_equal(
          <<~HTML,
            <button type="button" class="toggle foo">
              <div>Text</div>
            </button>
          HTML
          dropdown_builder.toggle(class: 'foo') { content_tag('div', 'Text') }
        )
      end

      # #popover

      def test_popover
        assert_dom_equal(
          <<~HTML,
            <div class="popover">
              Content
            </button>
          HTML
          dropdown_builder.popover('Content')
        )
      end

      def test_popover_with_class
        assert_dom_equal(
          <<~HTML,
            <div class="popover foo">
              Content
            </button>
          HTML
          dropdown_builder.popover('Content', class: 'foo')
        )
      end

      def test_popover_with_block
        assert_dom_equal(
          <<~HTML,
            <div class="popover">
              <div>Text</div>
            </button>
          HTML
          dropdown_builder.popover { content_tag('div', 'Text') }
        )
      end

      def test_popover_with_class_and_block
        assert_dom_equal(
          <<~HTML,
            <div class="popover foo">
              <div>Text</div>
            </button>
          HTML
          dropdown_builder.popover(class: 'foo') { content_tag('div', 'Text') }
        )
      end

      private

      def dropdown_builder(options = {})
        DropdownBuilder.new(self, FieldOptions.new(options))
      end
    end
  end
end
