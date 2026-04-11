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
              <#{tag_name}>Content</#{tag_name}>
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
              <#{tag_name}>Content</#{tag_name}>
            HTML
            table_row_builder.send(name) { 'Content' }
          )
        end

        define_method(:"test_#{name}_with_block_and_options") do
          assert_dom_equal(
            <<~HTML,
              <#{tag_name} class="foo-class">Content</#{tag_name}>
            HTML
            table_row_builder.send(name, class: 'foo-class') { 'Content' }
          )
        end
      end

      def test_data_on_model
        model_class = Struct.new(:foo, keyword_init: true)
        assert_dom_equal(
          <<~HTML,
            <td>bar</td>
          HTML
          table_row_builder(model_class.new(foo: 'bar')).data(:foo)
        )
        assert_dom_equal(
          <<~HTML,
            <td>-</td>
          HTML
          table_row_builder(model_class.new(foo: nil)).data(:foo, blank: '-')
        )
      end

      def test_header_on_model
        model_class = Class.new do
          def self.human_attribute_name(attribute)
            attribute.to_s.humanize
          end
        end
        [model_class, model_class.new].each do |model|
          assert_dom_equal(
            <<~HTML,
              <th>Foo</th>
            HTML
            table_row_builder(model).header(:foo)
          )
        end
      end

      private

      def table_row_builder(model = nil)
        TableRowBuilder.new(self, model)
      end
    end
  end
end
