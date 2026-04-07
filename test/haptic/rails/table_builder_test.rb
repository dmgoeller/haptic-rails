# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class TableBuilderTest < ActionView::TestCase

      def test_row
        assert_dom_equal(
          <<~HTML,
            <tr is="haptic-table-row"></tr>
          HTML
          table_builder.row
        )
      end

      def test_row_with_options
        assert_dom_equal(
          <<~HTML,
            <tr is="haptic-table-row" data-href="/" data-foo="bar"></tr>
          HTML
          table_builder.row(href: '/', data: { foo: 'bar' })
        )
      end

      def test_row_with_block
        assert_dom_equal(
          <<~HTML,
            <tr is="haptic-table-row">
              <td>Data</td>
            </tr>
          HTML
          table_builder.row do |row|
            row.data('Data')
          end
        )
      end

      def test_row_with_block_and_options
        assert_dom_equal(
          <<~HTML,
            <tr is="haptic-table-row" data-href="/" data-foo="bar">
              <td>Data</td>
            </tr>
          HTML
          table_builder.row(href: '/', data: { foo: 'bar' }) do |row|
            row.data('Data')
          end
        )
      end

      private

      def table_builder
        TableBuilder.new(self)
      end
    end
  end
end
