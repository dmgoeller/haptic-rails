# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class TableLikeBuilderTest < ActionView::TestCase
      # #row

      def test_row
        assert_dom_equal(
          <<~HTML,
            <a class="table-row"></a>
          HTML
          table_like_builder.row
        )
      end

      def test_row_with_options
        assert_dom_equal(
          <<~HTML,
            <a class="table-row" href="/" data-foo="bar"></a>
          HTML
          table_like_builder.row(href: '/', data: { foo: 'bar' })
        )
      end

      def test_row_with_block
        assert_dom_equal(
          <<~HTML,
            <a class="table-row">
              <div>Data</div>
            </a>
          HTML
          table_like_builder.row { tag.div('Data') }
        )
      end

      def test_row_with_block_and_options
        assert_dom_equal(
          <<~HTML,
            <a class="table-row" href="/" data-foo="bar">
              <div>Data</div>
            </a>
          HTML
          table_like_builder.row(href: '/', data: { foo: 'bar' }) do
            tag.div('Data')
          end
        )
      end

      # #row_to

      def test_row_to
        assert_dom_equal(
          <<~HTML,
            <a class="table-row" href="/foo"></a>
          HTML
          table_like_builder.row_to('/foo')
        )
      end

      def test_row_to_with_options
        assert_dom_equal(
          <<~HTML,
            <a class="table-row" href="/foo" data-foo="bar"></a>
          HTML
          table_like_builder.row_to('/foo', data: { foo: 'bar' })
        )
      end

      def test_row_to_with_block
        assert_dom_equal(
          <<~HTML,
            <a class="table-row" href="/foo">
              <div>Data</div>
            </a>
          HTML
          table_like_builder.row_to('/foo') do
            tag.div('Data')
          end
        )
      end

      def test_row_to_with_block_and_options
        assert_dom_equal(
          <<~HTML,
            <a class="table-row" href="/foo" data-foo="bar">
              <div>Data</div>
            </a>
          HTML
          table_like_builder.row_to('/foo', data: { foo: 'bar' }) do
            tag.div('Data')
          end
        )
      end

      private

      def table_like_builder
        TableLikeBuilder.new(self)
      end
    end
  end
end
