# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class PopoverBuilderTest < ActionView::TestCase
      def test_segment
        assert_dom_equal(
          <<~HTML,
            <div class="segment">
              <div>Content</div>
            </div>
          HTML
          popover_builder.segment { content_tag('div', 'Content') }
        )
      end

      def test_segment_with_legend
        assert_dom_equal(
          <<~HTML,
            <div class="segment">
              <div class="legend">Legend</div>
              <div>Content</div>
            </div>
          HTML
          popover_builder.segment('Legend') { content_tag('div', 'Content') }
        )
      end

      def test_segment_with_class
        assert_dom_equal(
          <<~HTML,
            <div class="segment foo">
              <div>Content</div>
            </div>
          HTML
          popover_builder.segment(class: 'foo') { content_tag('div', 'Content') }
        )
      end

      private

      def popover_builder
        PopoverBuilder.new(self)
      end
    end
  end
end
