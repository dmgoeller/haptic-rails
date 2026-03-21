# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class TableHelperTest < ActionView::TestCase
        include TableHelper

        # #haptic_table

        def test_haptic_table
          assert_dom_equal(
            <<~HTML,
              <table is="haptic-table"></table>
            HTML
            haptic_table
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

        # #haptic_table_like

        def test_haptic_table_like
          assert_dom_equal(
            <<~HTML,
              <haptic-table-like></haptic-table-like>
            HTML
            haptic_table_like
          )
        end

        def test_haptic_table_like_with_options
          assert_dom_equal(
            <<~HTML,
              <haptic-table-like foo="bar"></haptic-table-like>
            HTML
            haptic_table_like(foo: 'bar')
          )
        end

        def test_haptic_table_like_with_block
          assert_dom_equal(
            <<~HTML,
              <haptic-table-like>
                <a class="table-row">
                  <div>Data</div>
                </a>
              </haptic-table-like>
            HTML
            haptic_table_like do |table|
              table.row do
                content_tag('div', 'Data')
              end
            end
          )
        end

        def test_haptic_table_like_with_block_and_options
          assert_dom_equal(
            <<~HTML,
              <haptic-table-like foo="bar">
                <a class="table-row">
                  <div>Data</div>
                </a>
              </haptic-table-like>
            HTML
            haptic_table_like(foo: 'bar') do |table|
              table.row do
                content_tag('div', 'Data')
              end
            end
          )
        end
      end
    end
  end
end
