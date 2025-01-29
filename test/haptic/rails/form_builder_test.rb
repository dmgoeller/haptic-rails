# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class FormBuilderTest < ActionView::TestCase
      include Haptic::Rails::Helpers::FormTagHelper

      %i[file number text].each do |type|
        define_method("test_#{type}_field") do
          assert_dom_equal(
            <<~HTML,
              <input is="haptic-input" type="#{type}" name="dummy[foo]" id="dummy_foo">
            HTML
            form_builder.send(:"#{type}_field", :foo)
          )
        end

        define_method("test_#{type}_field_with_option") do
          assert_dom_equal(
            <<~HTML,
              <input is="haptic-input" type="#{type}" name="dummy[foo]" id="dummy_foo" bar="">
            HTML
            form_builder.send(:"#{type}_field", :foo, bar: '')
          )
        end

        define_method("test_#{type}_field_with_field_id") do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_foo" id="bar">
                <div class="haptic-field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[foo]" id="dummy_foo">
                </div>
              </haptic-text-field>
            HTML
            form_builder.send(:"#{type}_field", :foo, field_id: 'bar')
          )
        end

        define_method("test_#{type}_field_with_clear_button") do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_foo">
                <div class="haptic-field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[foo]" id="dummy_foo">
                  <button type="button" tabindex="-1" class="clear-button">
                    <div class="haptic-icon">close</div>
                  </button>
                </div>
              </haptic-text-field>
            HTML
            form_builder.send(:"#{type}_field", :foo, clear_button: true)
          )
        end

        %w[leading trailing].each do |position|
          define_method("test_#{type}_field_with_#{position}_icon") do
            assert_dom_equal(
              <<~HTML,
                <haptic-text-field for="dummy_foo">
                  <div class="haptic-field-container">
                    <input is="haptic-input" type="#{type}" name="dummy[foo]" id="dummy_foo">
                    <div class="haptic-icon #{position}-icon">bar</div>
                  </div>
                </haptic-text-field>
              HTML
              form_builder.send(:"#{type}_field", :foo, { "#{position}_icon": 'bar' })
            )
          end
        end

        define_method("test_#{type}_field_with_error_icon") do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_foo">
                <div class="haptic-field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[foo]" id="dummy_foo">
                  <div class="haptic-icon error-icon">error</div>
                </div>
              </haptic-text-field>
            HTML
            form_builder.send(:"#{type}_field", :foo, show_error_icon: true)
          )
        end

        define_method("test_#{type}_field_with_label") do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_foo">
                <div class="haptic-field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[foo]" id="dummy_foo">
                  <label is="haptic-label" class="haptic-field-label" for="dummy_foo">Foo</label>
                </div>
              </haptic-text-field>
            HTML
            form_builder.send(:"#{type}_field", :foo, label: true)
          )
        end

        define_method("test_#{type}_field_with_supporting_text") do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_foo">
                <div class="haptic-field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[foo]" id="dummy_foo">
                </div>
                <div class="supporting-text">Supporting text</div>
              </haptic-text-field>
            HTML
            form_builder.send(:"#{type}_field", :foo, supporting_text: 'Supporting text')
          )
        end

        define_method("test_#{type}_field_with_error_message") do
          dummy = Dummy.new
          dummy.errors.add(:foo, :invalid)

          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_foo" invalid="">
                <div class="haptic-field-container">
                  <div class="field_with_errors">
                    <input is="haptic-input" type="#{type}" name="dummy[foo]" id="dummy_foo">
                  </div>
                </div>
                <div class="error-message">Foo is invalid.</div>
              </haptic-text-field>
            HTML
            form_builder(dummy).send(:"#{type}_field", :foo, show_error_message: true)
          )
        end

        define_method("test_#{type}_field_with_set_valid_on_change") do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_foo" set-valid-on-change="dummy_bar">
                <div class="haptic-field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[foo]" id="dummy_foo">
                </div>
              </haptic-text-field>
            HTML
            form_builder.send(:"#{type}_field", :foo, set_valid_on_change: :bar)
          )
        end
      end

      def test_text_area
        assert_dom_equal(
          <<~HTML,
            <textarea is="haptic-textarea" name="dummy[foo]" id="dummy_foo"></textarea>
          HTML
          form_builder.text_area(:foo)
        )
      end

      def test_text_area_with_option
        assert_dom_equal(
          <<~HTML,
            <textarea is="haptic-textarea" name="dummy[foo]" id="dummy_foo" bar=""></textarea>
          HTML
          form_builder.text_area(:foo, bar: '')
        )
      end

      def test_text_area_with_field_id
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_foo" id="bar">
              <div class="haptic-field-container">
                <textarea is="haptic-textarea" name="dummy[foo]" id="dummy_foo"></textarea>
              </div>
            </haptic-text-field>
          HTML
          form_builder.text_area(:foo, field_id: :bar)
        )
      end

      def test_text_area_with_clear_button
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_foo">
              <div class="haptic-field-container">
                <textarea is="haptic-textarea" name="dummy[foo]" id="dummy_foo"></textarea>
                <button type="button" tabindex="-1" class="clear-button">
                  <div class="haptic-icon">close</div>
                </button>
              </div>
            </haptic-text-field>
          HTML
          form_builder.text_area(:foo, clear_button: true)
        )
      end

      %w[leading trailing].each do |position|
        define_method "test_text_area_with_#{position}_icon" do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_foo">
                <div class="haptic-field-container">
                  <textarea is="haptic-textarea" name="dummy[foo]" id="dummy_foo"></textarea>
                  <div class="haptic-icon #{position}-icon">bar</div>
                </div>
              </haptic-text-field>
            HTML
            form_builder.text_area(:foo, { "#{position}_icon": 'bar' })
          )
        end
      end

      def test_text_area_with_error_icon
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_foo">
              <div class="haptic-field-container">
                <textarea is="haptic-textarea" name="dummy[foo]" id="dummy_foo"></textarea>
                <div class="haptic-icon error-icon">error</div>
              </div>
            </haptic-text-field>
          HTML
          form_builder.text_area(:foo, show_error_icon: true)
        )
      end

      def test_text_area_with_label
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_foo">
              <div class="haptic-field-container">
                <textarea is="haptic-textarea" name="dummy[foo]" id="dummy_foo"></textarea>
                <label is="haptic-label" class="haptic-field-label" for="dummy_foo">Foo</label>
              </div>
            </haptic-text-field>
          HTML
          form_builder.text_area(:foo, label: true)
        )
      end

      def test_text_area_with_supporting_text
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_foo">
              <div class="haptic-field-container">
                <textarea is="haptic-textarea" name="dummy[foo]" id="dummy_foo"></textarea>
              </div>
              <div class="supporting-text">Supporting text</div>
            </haptic-text-field>
          HTML
          form_builder.text_area(:foo, supporting_text: 'Supporting text')
        )
      end

      def test_text_area_with_error_message
        dummy = Dummy.new
        dummy.errors.add(:foo, :invalid)

        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_foo" invalid="">
              <div class="haptic-field-container">
                <div class="field_with_errors">
                  <textarea is="haptic-textarea" name="dummy[foo]" id="dummy_foo"></textarea>
                </div>
              </div>
              <div class="error-message">Foo is invalid.</div>
            </haptic-text-field>
          HTML
          form_builder(dummy).text_area(:foo, show_error_message: true)
        )
      end

      def test_text_area_with_set_valid_on_change
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_foo" set-valid-on-change="dummy_bar">
              <div class="haptic-field-container">
                <textarea is="haptic-textarea" name="dummy[foo]" id="dummy_foo"></textarea>
              </div>
            </haptic-text-field>
          HTML
          form_builder.text_area(:foo, set_valid_on_change: :bar)
        )
      end

      def test_chips
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="dummy[foo][]" value="" autocomplete="off">
            <div class="haptic-chip">
              <input type="checkbox" value="foo" name="dummy[foo][]" id="dummy_foo_foo">
              <label for="dummy_foo_foo">Foo</label>
            </div>
            <div class="haptic-chip">
              <input type="checkbox" value="bar" name="dummy[foo][]" id="dummy_foo_bar">
              <label for="dummy_foo_bar">Bar</label>
            </div>
          HTML
          form_builder.chips(:foo, [%w[Foo foo], %w[Bar bar]])
        )
      end

      def test_chips_on_hash
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="dummy[foo][]" value="" autocomplete="off">
            <div class="haptic-chip">
              <input type="checkbox" value="foo" name="dummy[foo][]" id="dummy_foo_foo">
              <label for="dummy_foo_foo">Foo</label>
            </div>
            <div class="haptic-chip">
              <input type="checkbox" value="bar" name="dummy[foo][]" id="dummy_foo_bar">
              <label for="dummy_foo_bar">Bar</label>
            </div>
          HTML
          form_builder.chips(:foo, { 'Foo' => 'foo', 'Bar' => 'bar' })
        )
      end

      def test_chips_with_block
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="dummy[foo][]" value="" autocomplete="off">
            <div class="haptic-chip">
              <input type="checkbox" value="foo" name="dummy[foo][]" id="dummy_foo_foo" data-foo="bar">
              <label for="dummy_foo_foo">Foo</label>
            </div>
            <div class="haptic-chip">
              <input type="checkbox" value="bar" name="dummy[foo][]" id="dummy_foo_bar" data-foo="bar">
              <label for="dummy_foo_bar">Bar</label>
            </div>
          HTML
          form_builder.chips(:foo, [%w[Foo foo], %w[Bar bar]]) do |builder|
            builder.check_box(is: nil, data: { foo: 'bar' }) + builder.label(is: nil)
          end
        )
      end

      def test_list
        assert_dom_equal(
          <<~HTML,
            <haptic-list>
              <input type="hidden" name="dummy[foo]" value="" autocomplete="off">
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="foo" name="dummy[foo]" id="dummy_foo_foo">
                <label is="haptic-label" for="dummy_foo_foo">Foo</label>
              </haptic-list-item>
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="bar" name="dummy[foo]" id="dummy_foo_bar">
                <label is="haptic-label" for="dummy_foo_bar">Bar</label>
              </haptic-list-item>
            </haptic-list>
          HTML
          form_builder.list(:foo, [%w[Foo foo], %w[Bar bar]])
        )
      end

      def test_list_on_hash
        assert_dom_equal(
          <<~HTML,
            <haptic-list>
              <input type="hidden" name="dummy[foo]" value="" autocomplete="off">
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="foo" name="dummy[foo]" id="dummy_foo_foo">
                <label is="haptic-label" for="dummy_foo_foo">Foo</label>
              </haptic-list-item>
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="bar" name="dummy[foo]" id="dummy_foo_bar">
                <label is="haptic-label" for="dummy_foo_bar">Bar</label>
              </haptic-list-item>
            </haptic-list>
          HTML
          form_builder.list(:foo, { 'Foo' => 'foo', 'Bar' => 'bar' })
        )
      end

      def test_list_with_block
        assert_dom_equal(
          <<~HTML,
            <haptic-list>
              <input type="hidden" name="dummy[foo]" value="" autocomplete="off">
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="foo" name="dummy[foo]" id="dummy_foo_foo" data-foo="bar">
                <label is="haptic-label" for="dummy_foo_foo">Foo</label>
              </haptic-list-item>
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="bar" name="dummy[foo]" id="dummy_foo_bar" data-foo="bar">
                <label is="haptic-label" for="dummy_foo_bar">Bar</label>
              </haptic-list-item>
            </haptic-list>
          HTML
          form_builder.list(:foo, [%w[Foo foo], %w[Bar bar]]) do |builder|
            builder.radio_button(data: { foo: 'bar' }) + builder.label
          end
        )
      end

      def test_segmented_button
        assert_dom_equal(
          <<~HTML,
            <haptic-segmented-button>
              <input type="hidden" name="dummy[foo]" value="" autocomplete="off">
              <div class="haptic-button-segment">
                <input type="radio" value="foo" name="dummy[foo]" id="dummy_foo_foo">
                <label for="dummy_foo_foo">Foo</label>
              </div>
              <div class="haptic-button-segment">
                <input type="radio" value="bar" name="dummy[foo]" id="dummy_foo_bar">
                <label for="dummy_foo_bar">Bar</label>
              </div>
            </haptic-segmented-button>
          HTML
          form_builder.segmented_button(:foo, [%w[Foo foo], %w[Bar bar]])
        )
      end

      def test_segmented_button_on_hash
        assert_dom_equal(
          <<~HTML,
            <haptic-segmented-button>
              <input type="hidden" name="dummy[foo]" value="" autocomplete="off">
              <div class="haptic-button-segment">
                <input type="radio" value="foo" name="dummy[foo]" id="dummy_foo_foo">
                <label for="dummy_foo_foo">Foo</label>
              </div>
              <div class="haptic-button-segment">
                <input type="radio" value="bar" name="dummy[foo]" id="dummy_foo_bar">
                <label for="dummy_foo_bar">Bar</label>
              </div>
            </haptic-segmented-button>
          HTML
          form_builder.segmented_button(:foo, { 'Foo' => 'foo', 'Bar' => 'bar' })
        )
      end

      def test_segmented_button_with_block
        assert_dom_equal(
          <<~HTML,
            <haptic-segmented-button>
              <input type="hidden" name="dummy[foo]" value="" autocomplete="off">
              <div class="haptic-button-segment">
                <input type="radio" value="foo" name="dummy[foo]" id="dummy_foo_foo" data-foo="bar">
                <label for="dummy_foo_foo">Foo</label>
              </div>
              <div class="haptic-button-segment">
                <input type="radio" value="bar" name="dummy[foo]" id="dummy_foo_bar" data-foo="bar">
                <label for="dummy_foo_bar">Bar</label>
              </div>
            </haptic-segmented-button>
          HTML
          form_builder.segmented_button(:foo, [%w[Foo foo], %w[Bar bar]]) do |builder|
            builder.radio_button(is: nil, data: { foo: 'bar' }) + builder.label(is: nil)
          end
        )
      end

      def test_collection_list
        assert_dom_equal(
          <<~HTML,
            <haptic-list>
              <input type="hidden" name="dummy[foo]" value="" autocomplete="off">
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="foo" name="dummy[foo]" id="dummy_foo_foo">
                <label is="haptic-label" for="dummy_foo_foo">Foo</label>
              </haptic-list-item>
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="bar" name="dummy[foo]" id="dummy_foo_bar">
                <label is="haptic-label" for="dummy_foo_bar">Bar</label>
              </haptic-list-item>
            </haptic-list>
          HTML
          form_builder.collection_list(:foo, [%w[foo Foo], %w[bar Bar]], :first, :second)
        )
      end

      def test_collection_list_with_block
        assert_dom_equal(
          <<~HTML,
            <haptic-list>
              <input type="hidden" name="dummy[foo]" value="" autocomplete="off">
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="foo" name="dummy[foo]" id="dummy_foo_foo" data-foo="bar">
                <label is="haptic-label" for="dummy_foo_foo">Foo</label>
              </haptic-list-item>
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="bar" name="dummy[foo]" id="dummy_foo_bar" data-foo="bar">
                <label is="haptic-label" for="dummy_foo_bar">Bar</label>
              </haptic-list-item>
            </haptic-list>
          HTML
          form_builder.collection_list(:foo, [%w[foo Foo], %w[bar Bar]], :first, :second) do |builder|
            builder.radio_button(data: { foo: 'bar' }) + builder.label
          end
        )
      end

      def test_collection_list_on_multiple
        assert_dom_equal(
          <<~HTML,
            <haptic-list>
              <input type="hidden" name="dummy[foo][]" value="" autocomplete="off">
              <haptic-list-item>
                <input is="haptic-input" type="checkbox" value="foo" name="dummy[foo][]" id="dummy_foo_foo">
                <label is="haptic-label" for="dummy_foo_foo">Foo</label>
              </haptic-list-item>
              <haptic-list-item>
                <input is="haptic-input" type="checkbox" value="bar" name="dummy[foo][]" id="dummy_foo_bar">
                <label is="haptic-label" for="dummy_foo_bar">Bar</label>
              </haptic-list-item>
            </haptic-list>
          HTML
          form_builder.collection_list(:foo, [%w[foo Foo], %w[bar Bar]], :first, :second, multiple: true)
        )
      end

      def test_collection_select_dropdown
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_foo">
              <div class="haptic-field-container">
                <haptic-select-dropdown>
                  <input autocomplete="off" type="hidden" name="dummy[foo]" id="dummy_foo">
                  <div class="toggle haptic-field"></div>
                  <div class="popover">
                    <haptic-option-list>
                      <haptic-option value="foo">Foo</haptic-option>
                      <haptic-option value="bar">Bar</haptic-option>
                    </haptic-option-list>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form_builder.collection_select_dropdown(:foo, [%w[foo Foo], %w[bar Bar]], :first, :second)
        )
      end

      def test_dropdown_field
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field>
              <div class="haptic-field-container">
                <haptic-dialog-dropdown>
                  <div class="backdrop"></div>
                </haptic-dialog-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form_builder.dropdown_field
        )
      end

      def test_select_dropdown
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_foo">
              <div class="haptic-field-container">
                <haptic-select-dropdown>
                  <input autocomplete="off" type="hidden" name="dummy[foo]" id="dummy_foo">
                  <div class="toggle haptic-field"></div>
                  <div class="popover">
                    <haptic-option-list>
                      <haptic-option value="foo">Foo</haptic-option>
                      <haptic-option value="bar">Bar</haptic-option>
                    </haptic-option-list>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form_builder.select_dropdown(:foo, [%w[Foo foo], %w[Bar bar]])
        )
      end

      def test_select_dropdown_with_block
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_foo">
              <div class="haptic-field-container">
                <haptic-select-dropdown>
                  <input autocomplete="off" type="hidden" name="dummy[foo]" id="dummy_foo">
                  <div class="toggle haptic-field"></div>
                  <div class="popover">
                    <haptic-option-list>
                      <haptic-option value="foo">Foo</haptic-option>
                      <haptic-option value="bar">Bar</haptic-option>
                    </haptic-option-list>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form_builder.select_dropdown(:foo) do
            haptic_option_tag('Foo', value: 'foo') +
              haptic_option_tag('Bar', value: 'bar')
          end
        )
      end

      private

      def form_builder(dummy = nil, options = {})
        dummy, options = nil, dummy if dummy.is_a?(Hash)
        FormBuilder.new(:dummy, dummy || Dummy.new, self, options)
      end
    end
  end
end
