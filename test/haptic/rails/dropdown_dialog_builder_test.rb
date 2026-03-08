# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class DropdownDialogBuilderTest < ActionView::TestCase
      def test_popover
        assert_dom_equal(
          <<~HTML,
            <div class="popover">
              Content
            </button>
          HTML
          dropdown_dialog_builder.popover('Content')
        )
      end

      def test_popover_with_class
        assert_dom_equal(
          <<~HTML,
            <div class="popover foo">
              Content
            </button>
          HTML
          dropdown_dialog_builder.popover('Content', class: 'foo')
        )
      end

      def test_popover_with_block
        assert_dom_equal(
          <<~HTML,
            <div class="popover">
              <div>Text</div>
            </button>
          HTML
          dropdown_dialog_builder.popover { content_tag('div', 'Text') }
        )
      end

      def test_popover_with_class_and_block
        assert_dom_equal(
          <<~HTML,
            <div class="popover foo">
              <div>Text</div>
            </button>
          HTML
          dropdown_dialog_builder.popover(class: 'foo') { content_tag('div', 'Text') }
        )
      end

      private

      def dropdown_dialog_builder(options = {})
        DropdownDialogBuilder.new(self, FieldOptions.new(options))
      end
    end
  end
end
