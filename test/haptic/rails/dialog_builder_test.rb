# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class DialogBuilderTest < ActionView::TestCase
      # #header

      def test_header
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-header">Headline</div>
          HTML
          dialog_builder.header('Headline')
        )
      end

      def test_header_with_custom_class
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-header foo">Headline</div>
          HTML
          dialog_builder.header('Headline', class: 'foo')
        )
      end

      def test_header_with_block
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-header">
              <div class="headline">Headline</div>
              <div class="supporting-text">Supporting text</div>
            </div>
          HTML
          dialog_builder.header do
            content_tag('div', 'Headline', class: 'headline') +
              content_tag('div', 'Supporting text', class: 'supporting-text')
          end
        )
      end

      def test_header_with_custom_class_and_block
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-header foo">
              <div class="headline">Headline</div>
              <div class="supporting-text">Supporting text</div>
            </div>
          HTML
          dialog_builder.header(class: 'foo') do
            content_tag('div', 'Headline', class: 'headline') +
              content_tag('div', 'Supporting text', class: 'supporting-text')
          end
        )
      end

      # #segment

      def test_segment
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-segment"></div>
          HTML
          dialog_builder.segment
        )
      end

      def test_segment_with_custom_class
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-segment foo"></div>
          HTML
          dialog_builder.segment(class: 'foo')
        )
      end

      def test_segment_with_legend
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-segment">
              <div class="legend">Legend</div>
            </div>
          HTML
          dialog_builder.segment('Legend')
        )
      end

      def test_segment_with_legend_and_custom_class
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-segment foo">
              <div class="legend">Legend</div>
            </div>
          HTML
          dialog_builder.segment('Legend', class: 'foo')
        )
      end

      def test_segment_with_block
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-segment">
              <div>Content</div>
            </div>
          HTML
          dialog_builder.segment { content_tag('div', 'Content') }
        )
      end

      def test_segment_with_custom_class_and_block
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-segment foo">
              <div>Content</div>
            </div>
          HTML
          dialog_builder.segment(class: 'foo') { content_tag('div', 'Content') }
        )
      end

      def test_segment_with_legend_and_block
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-segment">
              <div class="legend">Legend</div>
              <div>Content</div>
            </div>
          HTML
          dialog_builder.segment('Legend') { content_tag('div', 'Content') }
        )
      end

      def test_segment_with_legend_custom_class_and_block
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-segment foo">
              <div class="legend">Legend</div>
              <div>Content</div>
            </div>
          HTML
          dialog_builder.segment('Legend', class: 'foo') { content_tag('div', 'Content') }
        )
      end

      private

      def dialog_builder
        DialogBuilder.new(self)
      end
    end
  end
end
