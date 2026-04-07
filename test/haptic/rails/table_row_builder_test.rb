# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class TableRowBuilderTest < ActionView::TestCase

      [[:data, 'td'], [:header, 'th']].each do |name, tag_name|
        define_method(:"test_#{name}") do
          assert_dom_equal(
            <<~HTML,
              <#{tag_name}></#{tag_name}>
            HTML
            table_row_builder.send(name)
          )
        end

        define_method(:"test_#{name}_with_options") do
          assert_dom_equal(
            <<~HTML,
              <#{tag_name} class="foo-class"></#{tag_name}>
            HTML
            table_row_builder.send(name, class: 'foo-class')
          )
        end

        define_method(:"test_#{name}_with_content") do
          assert_dom_equal(
            <<~HTML,
              <#{tag_name}>
                Content
              </#{tag_name}>
            HTML
            table_row_builder.send(name, 'Content')
          )
        end

        define_method(:"test_#{name}_with_content_and_options") do
          assert_dom_equal(
            <<~HTML,
              <#{tag_name} class="foo-class">
                Content
              </#{tag_name}>
            HTML
            table_row_builder.send(name, 'Content', class: 'foo-class')
          )
        end

        define_method(:"test_#{name}_with_block") do
          assert_dom_equal(
            <<~HTML,
              <#{tag_name}>
                Content
              </#{tag_name}>
            HTML
            table_row_builder.send(name) { 'Content' }
          )
        end

        define_method(:"test_#{name}_with_block_and_options") do
          assert_dom_equal(
            <<~HTML,
              <#{tag_name} class="foo-class">
                Content
              </#{tag_name}>
            HTML
            table_row_builder.send(name, class: 'foo-class') { 'Content' }
          )
        end
      end

      private

      def table_row_builder
        TableRowBuilder.new(self)
      end
    end
  end
end
