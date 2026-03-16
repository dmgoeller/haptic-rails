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

        def test_haptic_table_with_block
          assert_dom_equal(
            <<~HTML,
              <table is="haptic-table">
                <tr is="haptic-table-row">
                  <td>Cell</td>
                </tr>
              </table>
            HTML
            haptic_table do |table|
              table.row do |row|
                row.data 'Cell'
              end
            end
          )
        end
      end
    end
  end
end
