# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class TableLikeHelperTest < ActionView::TestCase
        include TableLikeHelper

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
              <haptic-table-like data-foo="bar"></haptic-table-like>
            HTML
            haptic_table_like(data: { foo: 'bar' })
          )
        end

        def test_haptic_table_like_with_block
          assert_dom_equal(
            <<~HTML,
              <haptic-table-like>
                <div class="table-row">Data</div>
              </haptic-table-like>
            HTML
            haptic_table_like do |table|
              table.row { 'Data' }
            end
          )
        end

        def test_haptic_table_like_with_block_and_options
          assert_dom_equal(
            <<~HTML,
              <haptic-table-like data-foo="bar">
                <div class="table-row">Data</div>
              </haptic-table-like>
            HTML
            haptic_table_like(data: { foo: 'bar' }) do |table|
              table.row { 'Data' }
            end
          )
        end
      end
    end
  end
end
