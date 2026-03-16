# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class TableRowBuilderTest < ActionView::TestCase

      [[:data, 'td'], [:header, 'th']].each do |name, tag_name|
        define_method(:"test_#{name}_with_custom_class") do
          assert_dom_equal(
            <<~HTML,
              <#{tag_name} class="foo"></#{tag_name}>
            HTML
            table_row_builder.send(name, class: 'foo')
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

        define_method(:"test_#{name}_with_content_and_custom_class") do
          assert_dom_equal(
            <<~HTML,
              <#{tag_name} class="foo">
                Content
              </#{tag_name}>
            HTML
            table_row_builder.send(name, 'Content', class: 'foo')
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

        define_method(:"test_#{name}_with_block_and_custom_class") do
          assert_dom_equal(
            <<~HTML,
              <#{tag_name} class="foo">
                Content
              </#{tag_name}>
            HTML
            table_row_builder.send(name, class: 'foo') { 'Content' }
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
