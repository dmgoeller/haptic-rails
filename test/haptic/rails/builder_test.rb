# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class BuilderTest < ActionView::TestCase
      %w[date file number text].each do |type|
        define_method("test_#{type}_field") do
          assert_dom_equal(
            <<~HTML,
              <input type="#{type}" is="haptic-input" name="foo[bar]" id="foo_bar">
            HTML
            builder.public_send("#{type}_field", :foo, :bar)
          )
        end

        define_method("test_#{type}_field_with_default_element_class") do
          assert_dom_equal(
            <<~HTML,
              <input type="#{type}" name="foo[bar]" id="foo_bar">
            HTML
            builder.public_send("#{type}_field", :foo, :bar, is: nil)
          )
        end

        define_method("test_#{type}_field_with_additional_classes") do
          assert_dom_equal(
            <<~HTML,
              <input type="#{type}" is="haptic-input" name="foo[bar]" id="foo_bar" class="foo bar">
            HTML
            builder(class: 'foo').public_send("#{type}_field", :foo, :bar, class: 'bar')
          )
        end
      end

      def test_button_tag
        assert_dom_equal(
          <<~HTML,
            <button type="submit" is="haptic-button" name="button">Content</button>
          HTML
          builder.button_tag('Content')
        )
      end

      def test_button_tag_with_default_element_class
        assert_dom_equal(
          <<~HTML,
            <button type="submit" name="button">Content</button>
          HTML
          builder.button_tag('Content', is: nil)
        )
      end

      def test_button_tag_with_block
        assert_dom_equal(
          <<~HTML,
            <button type="submit" is="haptic-button" name="button">
              <div>Content</div>
            </label>
          HTML
          builder.button_tag { content_tag('div', 'Content') }
        )
      end

      def test_button_tag_with_default_element_class_and_block
        assert_dom_equal(
          <<~HTML,
            <button type="submit" name="button">
              <div>Content</div>
            </label>
          HTML
          builder.button_tag(is: nil) { content_tag('div', 'Content') }
        )
      end

      def test_check_box
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="foo[bar]" value="0" autocomplete="off">
            <input type="checkbox" is="haptic-input" value="1" name="foo[bar]" id="foo_bar">
          HTML
          builder.check_box(:foo, :bar)
        )
      end

      def test_check_box_with_default_element_class
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="foo[bar]" value="0" autocomplete="off">
            <input type="checkbox" value="1" name="foo[bar]" id="foo_bar">
          HTML
          builder.check_box(:foo, :bar, { is: nil })
        )
      end

      def test_collection_check_boxes
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="foo[bar][]" value="" autocomplete="off" />
            <input is="haptic-input" type="checkbox" value="foo" name="foo[bar][]" id="foo_bar_foo" />
            <label is="haptic-label" for="foo_bar_foo">Foo</label>
            <input is="haptic-input" type="checkbox" value="bar" name="foo[bar][]" id="foo_bar_bar" />
            <label is="haptic-label" for="foo_bar_bar">Bar</label>
          HTML
          builder.collection_check_boxes(:foo, :bar, [%w[foo Foo], %w[bar Bar]], :first, :second)
        )
      end

      def test_collection_radio_buttons
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="foo[bar]" value="" autocomplete="off" />
            <input is="haptic-input" type="radio" value="foo" name="foo[bar]" id="foo_bar_foo" />
            <label is="haptic-label" for="foo_bar_foo">Foo</label>
            <input is="haptic-input" type="radio" value="bar" name="foo[bar]" id="foo_bar_bar" />
            <label is="haptic-label" for="foo_bar_bar">Bar</label>
          HTML
          builder.collection_radio_buttons(:foo, :bar, [%w[foo Foo], %w[bar Bar]], :first, :second)
        )
      end

      def test_label
        assert_dom_equal(
          <<~HTML,
            <label is="haptic-label" for="foo_bar">Content</label>
          HTML
          builder.label(:foo, :bar, 'Content')
        )
      end

      def test_label_with_default_element_class
        assert_dom_equal(
          <<~HTML,
            <label for="foo_bar">Content</label>
          HTML
          builder.label(:foo, :bar, 'Content', is: nil)
        )
      end

      def test_label_with_block
        assert_dom_equal(
          <<~HTML,
            <label is="haptic-label" for="foo_bar">
              <div>Content</div>
            </label>
          HTML
          builder.label(:foo, :bar) { content_tag('div', 'Content') }
        )
      end

      def test_label_with_default_element_class_and_block
        assert_dom_equal(
          <<~HTML,
            <label for="foo_bar">
              <div>Content</div>
            </label>
          HTML
          builder.label(:foo, :bar, is: nil) { content_tag('div', 'Content') }
        )
      end

      def test_radio_button
        assert_dom_equal(
          <<~HTML,
            <input type="radio" is="haptic-input" name="foo[bar]" value="value" id="foo_bar_value">
          HTML
          builder.radio_button(:foo, :bar, 'value')
        )
      end

      def test_radio_button_with_default_element_class
        assert_dom_equal(
          <<~HTML,
            <input type="radio" name="foo[bar]" value="value" id="foo_bar_value">
          HTML
          builder.radio_button(:foo, :bar, 'value', is: nil)
        )
      end

      def test_select
        assert_dom_equal(
          <<~HTML,
            <select is="haptic-select" name="foo[bar]" id="foo_bar">
              <option value="foo">Foo</option>
              <option value="bar">Bar</option>
            </select>
          HTML
          builder.select(:foo, :bar, [%w[Foo foo], %w[Bar bar]])
        )
      end

      def test_select_with_default_element_class
        assert_dom_equal(
          <<~HTML,
            <select name="foo[bar]" id="foo_bar">
              <option value="foo">Foo</option>
              <option value="bar">Bar</option>
            </select>
          HTML
          builder.select(:foo, :bar, [%w[Foo foo], %w[Bar bar]], {}, { is: nil })
        )
      end

      def test_submit_tag
        assert_dom_equal(
          <<~HTML,
            <input type="submit" is="haptic-input" name="commit" value="Value" data-disable-with="Value">
          HTML
          builder.submit_tag('Value')
        )
      end

      def test_submit_tag_with_default_element_class
        assert_dom_equal(
          <<~HTML,
            <input type="submit" name="commit" value="Value" data-disable-with="Value">
          HTML
          builder.submit_tag('Value', is: nil)
        )
      end

      def test_text_area
        assert_dom_equal(
          <<~HTML,
            <textarea is="haptic-textarea" name="foo[bar]" id="foo_bar">
          HTML
          builder.text_area(:foo, :bar)
        )
      end

      def test_text_area_with_classes
        assert_dom_equal(
          <<~HTML,
            <textarea is="haptic-textarea" name="foo[bar]" id="foo_bar" class="foo bar">
          HTML
          builder(class: 'foo').text_area(:foo, :bar, class: 'bar')
        )
      end

      private

      def builder(options = {})
        Builder.new(self, FieldOptions.new(options))
      end
    end
  end
end
