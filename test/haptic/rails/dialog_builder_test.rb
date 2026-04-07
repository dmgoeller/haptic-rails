# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class DialogBuilderTest < ActionView::TestCase
      # #header

      def test_header
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-header"></div>
          HTML
          dialog_builder.header
        )
      end

      def test_header_with_options
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-header foo-class" data-foo="bar"></div>
          HTML
          dialog_builder.header(class: 'foo-class', data: { foo: 'bar' })
        )
      end

      def test_header_with_content
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-header">Headline</div>
          HTML
          dialog_builder.header('Headline')
        )
      end

      def test_header_with_content_and_options
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-header foo-class" data-foo="bar">Headline</div>
          HTML
          dialog_builder.header('Headline', class: 'foo-class', data: { foo: 'bar' })
        )
      end

      def test_header_with_block
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-header">
              <div class="headline">Headline</div>
              <div class="supporting-text">Helper text</div>
            </div>
          HTML
          dialog_builder.header do
            tag.div('Headline', class: 'headline') +
              tag.div('Helper text', class: 'supporting-text')
          end
        )
      end

      def test_header_with_block_and_options
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-header foo-class" data-foo="bar">
              <div class="headline">Headline</div>
              <div class="supporting-text">Helper text</div>
            </div>
          HTML
          dialog_builder.header(class: 'foo-class', data: { foo: 'bar' }) do
            tag.div('Headline', class: 'headline') +
              tag.div('Helper text', class: 'supporting-text')
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

      def test_segment_with_options
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-segment foo-class" data-foo="bar"></div>
          HTML
          dialog_builder.segment(class: 'foo-class', data: { foo: 'bar' })
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

      def test_segment_with_legend_and_options
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-segment foo-class" data-foo="bar">
              <div class="legend">Legend</div>
            </div>
          HTML
          dialog_builder.segment('Legend', class: 'foo-class', data: { foo: 'bar' })
        )
      end

      def test_segment_with_block
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-segment">
              <div>Content</div>
            </div>
          HTML
          dialog_builder.segment { tag.div('Content') }
        )
      end

      def test_segment_with_block_and_options
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-segment foo-class" data-foo="bar">
              <div>Content</div>
            </div>
          HTML
          dialog_builder.segment(class: 'foo-class', data: { foo: 'bar' }) do
            tag.div('Content')
          end
        )
      end

      def test_segment_with_block_and_legend
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-segment">
              <div class="legend">Legend</div>
              <div>Content</div>
            </div>
          HTML
          dialog_builder.segment('Legend') do
            tag.div('Content')
          end
        )
      end

      def test_segment_with_block_legend_and_options
        assert_dom_equal(
          <<~HTML,
            <div class="dialog-segment foo-class" data-foo="bar">
              <div class="legend">Legend</div>
              <div>Content</div>
            </div>
          HTML
          dialog_builder.segment('Legend', class: 'foo-class', data: { foo: 'bar' }) do
            tag.div('Content')
          end
        )
      end

      private

      def dialog_builder
        DialogBuilder.new(self)
      end
    end
  end
end
