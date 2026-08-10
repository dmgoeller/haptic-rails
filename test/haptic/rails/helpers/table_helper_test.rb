# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class TableHelperTest < ActionView::TestCase
        include TableHelper

        def test_haptic_table
          assert_dom_equal(
            <<~HTML,
              <table is="haptic-table"></table>
            HTML
            haptic_table
          )
        end

        def test_haptic_table_with_options
          assert_dom_equal(
            <<~HTML,
              <table is="haptic-table" data-foo="bar"></table>
            HTML
            haptic_table(data: { foo: 'bar' })
          )
        end

        def test_haptic_table_with_block
          assert_dom_equal(
            <<~HTML,
              <table is="haptic-table">
                <tr is="haptic-table-row">
                  <td>Data</td>
                </tr>
              </table>
            HTML
            haptic_table do |table|
              table.row do |row|
                row.data 'Data'
              end
            end
          )
        end

        def test_haptic_table_with_block_and_options
          assert_dom_equal(
            <<~HTML,
              <table is="haptic-table" data-foo="bar">
                <tr is="haptic-table-row">
                  <td>Data</td>
                </tr>
              </table>
            HTML
            haptic_table(data: { foo: 'bar' }) do |table|
              table.row do |row|
                row.data 'Data'
              end
            end
          )
        end
      end
    end
  end
end
