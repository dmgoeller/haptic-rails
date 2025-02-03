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
              <input is="haptic-input" type="#{type}" name="dummy[name]" id="dummy_name">
            HTML
            form.send(:"#{type}_field", :name)
          )
        end

        define_method("test_#{type}_field_with_field_options") do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_name" id="field-id" set-valid-on-change="dummy_bar">
                <div class="haptic-field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[name]" id="dummy_name">
                  <label is="haptic-label" class="haptic-field-label" for="dummy_name">Name</label>
                  <button type="button" tabindex="-1" class="clear-button">
                    <div class="haptic-icon">close</div>
                  </button>
                  <div class="haptic-icon leading-icon">leading_icon</div>
                  <div class="haptic-icon trailing-icon">trailing_icon</div>
                </div>
                <div class="supporting-text">Supporting text</div>
              </haptic-text-field>
            HTML
            form.send(
              :"#{type}_field",
              :name,
              clear_button: true,
              field_id: 'field-id',
              label: true,
              leading_icon: 'leading_icon',
              supporting_text: 'Supporting text',
              set_valid_on_change: :bar,
              trailing_icon: 'trailing_icon'
            )
          )
        end

        define_method("test_#{type}_field_with_custom_label") do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_name">
                <div class="haptic-field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[name]" id="dummy_name">
                  <label is="haptic-label" class="haptic-field-label" for="dummy_name">Label</label>
                </div>
              </haptic-text-field>
            HTML
            form.send(:"#{type}_field", :name, label: 'Label')
          )
        end

        define_method("test_#{type}_field_with_errors") do
          dummy = Dummy.new
          dummy.errors.add(:name, :invalid)

          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_name" invalid="">
                <div class="haptic-field-container">
                  <div class="field_with_errors">
                    <input is="haptic-input" type="#{type}" name="dummy[name]" id="dummy_name">
                  </div>
                  <div class="haptic-icon error-icon">error</div>
                </div>
                <div class="error-message">Name is invalid.</div>
              </haptic-text-field>
            HTML
            form(dummy).send(
              :"#{type}_field",
              :name,
              show_error_icon: true,
              show_error_message: true
            )
          )
        end

        define_method("test_#{type}_on_nil_object") do
          form = FormBuilder.new(:dummy, nil, self, {})
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_name">
                <div class="haptic-field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[name]" id="dummy_name">
                  <label is="haptic-label" class="haptic-field-label" for="dummy_name">Name</label>
                </div>
              </haptic-text-field>
            HTML
            form.send(:"#{type}_field", :name, label: true)
          )
        end
      end

      def test_text_area
        assert_dom_equal(
          <<~HTML,
            <textarea is="haptic-textarea" name="dummy[name]" id="dummy_name"></textarea>
          HTML
          form.text_area(:name)
        )
      end

      def test_text_area_with_field_options
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_name" id="field-id" set-valid-on-change="dummy_bar">
              <div class="haptic-field-container">
                <textarea is="haptic-textarea" name="dummy[name]" id="dummy_name"></textarea>
                <label is="haptic-label" class="haptic-field-label" for="dummy_name">Name</label>
                <button type="button" tabindex="-1" class="clear-button">
                  <div class="haptic-icon">close</div>
                </button>
                <div class="haptic-icon leading-icon">leading_icon</div>
                <div class="haptic-icon trailing-icon">trailing_icon</div>
              </div>
              <div class="supporting-text">Supporting text</div>
            </haptic-text-field>
          HTML
          form.text_area(
            :name,
            clear_button: true,
            field_id: 'field-id',
            label: true,
            leading_icon: 'leading_icon',
            supporting_text: 'Supporting text',
            set_valid_on_change: :bar,
            trailing_icon: 'trailing_icon'
          )
        )
      end

      def test_text_area_with_custom_label
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_name">
              <div class="haptic-field-container">
                <textarea is="haptic-textarea" name="dummy[name]" id="dummy_name"></textarea>
                <label is="haptic-label" class="haptic-field-label" for="dummy_name">Label</label>
              </div>
            </haptic-text-field>
          HTML
          form.text_area(:name, label: 'Label')
        )
      end

      def test_text_area_with_errors
        dummy = Dummy.new
        dummy.errors.add(:name, :invalid)

        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_name" invalid="">
              <div class="haptic-field-container">
                <div class="field_with_errors">
                  <textarea is="haptic-textarea" name="dummy[name]" id="dummy_name"></textarea>
                </div>
                <div class="haptic-icon error-icon">error</div>
              </div>
              <div class="error-message">Name is invalid.</div>
            </haptic-text-field>
          HTML
          form(dummy).text_area(:name, show_error_icon: true, show_error_message: true)
        )
      end

      def test_text_area_on_nil_object
        form = FormBuilder.new(:dummy, nil, self, {})
        assert_dom_equal(
          <<~HTML,
            <textarea is="haptic-textarea" name="dummy[name]" id="dummy_name"></textarea>
          HTML
          form.text_area(:name)
        )
      end

      def test_chips
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="dummy[color][]" value="" autocomplete="off">
            <div class="haptic-chip">
              <input type="checkbox" value="blue" name="dummy[color][]" id="dummy_color_blue">
              <label for="dummy_color_blue">Blue</label>
            </div>
            <div class="haptic-chip">
              <input type="checkbox" value="green" name="dummy[color][]" id="dummy_color_green">
              <label for="dummy_color_green">Green</label>
            </div>
          HTML
          form.chips(:color, [%w[Blue blue], %w[Green green]])
        )
      end

      def test_chips_on_choices_as_hash
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="dummy[color][]" value="" autocomplete="off">
            <div class="haptic-chip">
              <input type="checkbox" value="blue" name="dummy[color][]" id="dummy_color_blue">
              <label for="dummy_color_blue">Blue</label>
            </div>
            <div class="haptic-chip">
              <input type="checkbox" value="green" name="dummy[color][]" id="dummy_color_green">
              <label for="dummy_color_green">Green</label>
            </div>
          HTML
          form.chips(:color, { 'Blue' => 'blue', 'Green' => 'green' })
        )
      end

      def test_chips_with_block
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="dummy[color][]" value="" autocomplete="off">
            <div class="haptic-chip">
              <input type="checkbox" value="blue" name="dummy[color][]" id="dummy_color_blue"
                checked="checked">
              <label for="dummy_color_blue">Blue</label>
            </div>
            <div class="haptic-chip">
              <input type="checkbox" value="green" name="dummy[color][]" id="dummy_color_green">
              <label for="dummy_color_green">Green</label>
            </div>
          HTML
          form.chips(:color, [%w[Blue blue], %w[Green green]]) do |b|
            b.check_box(is: nil, checked: b.value == 'blue') + b.label(is: nil)
          end
        )
      end

      def test_list
        assert_dom_equal(
          <<~HTML,
            <haptic-list>
              <input type="hidden" name="dummy[color]" value="" autocomplete="off">
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="blue" name="dummy[color]"
                  id="dummy_color_blue">
                <label is="haptic-label" for="dummy_color_blue">Blue</label>
              </haptic-list-item>
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="green" name="dummy[color]"
                  id="dummy_color_green">
                <label is="haptic-label" for="dummy_color_green">Green</label>
              </haptic-list-item>
            </haptic-list>
          HTML
          form.list(:color, [%w[Blue blue], %w[Green green]])
        )
      end

      def test_list_on_choices_as_hash
        assert_dom_equal(
          <<~HTML,
            <haptic-list>
              <input type="hidden" name="dummy[color]" value="" autocomplete="off">
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="blue" name="dummy[color]"
                  id="dummy_color_blue">
                <label is="haptic-label" for="dummy_color_blue">Blue</label>
              </haptic-list-item>
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="green" name="dummy[color]"
                  id="dummy_color_green">
                <label is="haptic-label" for="dummy_color_green">Green</label>
              </haptic-list-item>
            </haptic-list>
          HTML
          form.list(:color, { 'Blue' => 'blue', 'Green' => 'green' })
        )
      end

      def test_list_with_block
        assert_dom_equal(
          <<~HTML,
            <haptic-list>
              <input type="hidden" name="dummy[color]" value="" autocomplete="off">
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="blue" name="dummy[color]"
                  id="dummy_color_blue" checked="checked">
                <label is="haptic-label" for="dummy_color_blue">Blue</label>
              </haptic-list-item>
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="green" name="dummy[color]"
                  id="dummy_color_green">
                <label is="haptic-label" for="dummy_color_green">Green</label>
              </haptic-list-item>
            </haptic-list>
          HTML
          form.list(:color, [%w[Blue blue], %w[Green green]]) do |b|
            b.radio_button(checked: b.value == 'blue') + b.label
          end
        )
      end

      def test_segmented_button
        assert_dom_equal(
          <<~HTML,
            <haptic-segmented-button>
              <input type="hidden" name="dummy[color]" value="" autocomplete="off">
              <div class="haptic-button-segment">
                <input type="radio" value="blue" name="dummy[color]" id="dummy_color_blue">
                <label for="dummy_color_blue">Blue</label>
              </div>
              <div class="haptic-button-segment">
                <input type="radio" value="green" name="dummy[color]" id="dummy_color_green">
                <label for="dummy_color_green">Green</label>
              </div>
            </haptic-segmented-button>
          HTML
          form.segmented_button(:color, [%w[Blue blue], %w[Green green]])
        )
      end

      def test_segmented_button_on_choices_as_hash
        assert_dom_equal(
          <<~HTML,
            <haptic-segmented-button>
              <input type="hidden" name="dummy[color]" value="" autocomplete="off">
              <div class="haptic-button-segment">
                <input type="radio" value="blue" name="dummy[color]" id="dummy_color_blue">
                <label for="dummy_color_blue">Blue</label>
              </div>
              <div class="haptic-button-segment">
                <input type="radio" value="green" name="dummy[color]" id="dummy_color_green">
                <label for="dummy_color_green">Green</label>
              </div>
            </haptic-segmented-button>
          HTML
          form.segmented_button(:color, { 'Blue' => 'blue', 'Green' => 'green' })
        )
      end

      def test_segmented_button_with_block
        assert_dom_equal(
          <<~HTML,
            <haptic-segmented-button>
              <input type="hidden" name="dummy[color]" value="" autocomplete="off">
              <div class="haptic-button-segment">
                <input type="radio" value="blue" name="dummy[color]" id="dummy_color_blue"
                  checked="checked">
                <label for="dummy_color_blue">Blue</label>
              </div>
              <div class="haptic-button-segment">
                <input type="radio" value="green" name="dummy[color]" id="dummy_color_green">
                <label for="dummy_color_green">Green</label>
              </div>
            </haptic-segmented-button>
          HTML
          form.segmented_button(:color, [%w[Blue blue], %w[Green green]]) do |b|
            b.radio_button(is: nil, checked: b.value == 'blue') + b.label(is: nil)
          end
        )
      end

      def test_collection_chips
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="dummy[color][]" value="" autocomplete="off">
            <div class="haptic-chip">
              <input type="checkbox" value="blue" name="dummy[color][]" id="dummy_color_blue">
              <label for="dummy_color_blue">Blue</label>
            </div>
            <div class="haptic-chip">
              <input type="checkbox" value="green" name="dummy[color][]" id="dummy_color_green">
              <label for="dummy_color_green">Green</label>
            </div>
          HTML
          form.collection_chips(:color, %w[Blue Green], :downcase, :itself)
        )
      end

      def test_collection_chips_with_block
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="dummy[color][]" value="" autocomplete="off">
            <div class="haptic-chip">
              <input type="checkbox" value="blue" name="dummy[color][]" id="dummy_color_blue"
                checked="checked">
              <label for="dummy_color_blue">Blue</label>
            </div>
            <div class="haptic-chip">
              <input type="checkbox" value="green" name="dummy[color][]" id="dummy_color_green">
              <label for="dummy_color_green">Green</label>
            </div>
          HTML
          form.collection_chips(:color, %w[Blue Green], :downcase, :itself) do |b|
            b.check_box(is: nil, checked: b.value == 'blue') + b.label(is: nil)
          end
        )
      end

      def test_collection_list
        assert_dom_equal(
          <<~HTML,
            <haptic-list>
              <input type="hidden" name="dummy[color]" value="" autocomplete="off">
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="blue" name="dummy[color]"
                  id="dummy_color_blue">
                <label is="haptic-label" for="dummy_color_blue">Blue</label>
              </haptic-list-item>
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="green" name="dummy[color]"
                  id="dummy_color_green">
                <label is="haptic-label" for="dummy_color_green">Green</label>
              </haptic-list-item>
            </haptic-list>
          HTML
          form.collection_list(:color, %w[Blue Green], :downcase, :itself)
        )
      end

      def test_collection_list_with_block
        assert_dom_equal(
          <<~HTML,
            <haptic-list>
              <input type="hidden" name="dummy[color]" value="" autocomplete="off">
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="blue" name="dummy[color]"
                  id="dummy_color_blue" checked="checked">
                <label is="haptic-label" for="dummy_color_blue">Blue</label>
              </haptic-list-item>
              <haptic-list-item>
                <input is="haptic-input" type="radio" value="green" name="dummy[color]"
                  id="dummy_color_green">
                <label is="haptic-label" for="dummy_color_green">Green</label>
              </haptic-list-item>
            </haptic-list>
          HTML
          form.collection_list(:color, %w[Blue Green], :downcase, :itself) do |b|
            b.radio_button(checked: b.value == 'blue') + b.label
          end
        )
      end

      def test_collection_list_with_check_boxes
        assert_dom_equal(
          <<~HTML,
            <haptic-list>
              <input type="hidden" name="dummy[color][]" value="" autocomplete="off">
              <haptic-list-item>
                <input is="haptic-input" type="checkbox" value="blue" name="dummy[color][]"
                  id="dummy_color_blue">
                <label is="haptic-label" for="dummy_color_blue">Blue</label>
              </haptic-list-item>
              <haptic-list-item>
                <input is="haptic-input" type="checkbox" value="green" name="dummy[color][]"
                  id="dummy_color_green">
                <label is="haptic-label" for="dummy_color_green">Green</label>
              </haptic-list-item>
            </haptic-list>
          HTML
          form.collection_list(:color, %w[Blue Green], :downcase, :itself, multiple: true)
        )
      end

      def test_collection_list_with_check_boxes_and_block
        assert_dom_equal(
          <<~HTML,
            <haptic-list>
              <input type="hidden" name="dummy[color][]" value="" autocomplete="off">
              <haptic-list-item>
                <input is="haptic-input" type="checkbox" value="blue" name="dummy[color][]"
                  id="dummy_color_blue" checked="checked">
                <label is="haptic-label" for="dummy_color_blue">Blue</label>
              </haptic-list-item>
              <haptic-list-item>
                <input is="haptic-input" type="checkbox" value="green" name="dummy[color][]"
                  id="dummy_color_green">
                <label is="haptic-label" for="dummy_color_green">Green</label>
              </haptic-list-item>
            </haptic-list>
          HTML
          form.collection_list(:color, %w[Blue Green], :downcase, :itself, multiple: true) do |b|
            b.check_box(checked: b.value == 'blue') + b.label
          end
        )
      end

      def test_collection_segmented_button
        assert_dom_equal(
          <<~HTML,
            <haptic-segmented-button>
              <input type="hidden" name="dummy[color]" value="" autocomplete="off">
              <div class="haptic-button-segment">
                <input type="radio" value="blue" name="dummy[color]" id="dummy_color_blue">
                <label for="dummy_color_blue">Blue</label>
              </div>
              <div class="haptic-button-segment">
                <input type="radio" value="green" name="dummy[color]" id="dummy_color_green">
                <label for="dummy_color_green">Green</label>
              </div>
            </haptic-segmented-button>
          HTML
          form.collection_segmented_button(:color, %w[Blue Green], :downcase, :itself)
        )
      end

      def test_collection_segmented_button_with_block
        assert_dom_equal(
          <<~HTML,
            <haptic-segmented-button>
              <input type="hidden" name="dummy[color]" value="" autocomplete="off">
              <div class="haptic-button-segment">
                <input type="radio" value="blue" name="dummy[color]" id="dummy_color_blue"
                  checked="checked">
                <label for="dummy_color_blue">Blue</label>
              </div>
              <div class="haptic-button-segment">
                <input type="radio" value="green" name="dummy[color]" id="dummy_color_green">
                <label for="dummy_color_green">Green</label>
              </div>
            </haptic-segmented-button>
          HTML
          form.collection_segmented_button(:color, %w[Blue Green], :downcase, :itself) do |b|
            b.radio_button(is: nil, checked: b.value == 'blue') + b.label(is: nil)
          end
        )
      end

      def test_collection_select
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="haptic-field-container">
                <select name="dummy[color]" id="dummy_color">
                  <option value="blue">Blue</option>
                  <option value="green">Green</option>
                </select>
              </div>
            </haptic-dropdown-field>
          HTML
          form.collection_select(:color, %w[Blue Green], :downcase, :itself)
        )
      end

      def test_collection_select_with_field_options
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color" id="field-id" set-valid-on-change="dummy_bar">
              <div class="haptic-field-container">
                <select name="dummy[color]" id="dummy_color">
                  <option value="blue">Blue</option>
                  <option value="green">Green</option>
                </select>
                <label is="haptic-label" class="haptic-field-label" for="dummy_color">Color</label>
                <div class="haptic-icon leading-icon">leading_icon</div>
              </div>
              <div class="supporting-text">Supporting text</div>
            </haptic-dropdown-field>
          HTML
          form.collection_select(
            :color,
            %w[Blue Green],
            :downcase,
            :itself,
            {},
            {
              field_id: 'field-id',
              label: true,
              leading_icon: 'leading_icon',
              set_valid_on_change: :bar,
              supporting_text: 'Supporting text'
            }
          )
        )
      end

      def test_collection_select_with_custom_label
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="haptic-field-container">
                <select name="dummy[color]" id="dummy_color">
                  <option value="blue">Blue</option>
                  <option value="green">Green</option>
                </select>
                <label is="haptic-label" class="haptic-field-label" for="dummy_color">Label</label>
              </div>
            </haptic-dropdown-field>
          HTML
          form.collection_select(
            :color,
            %w[Blue Green],
            :downcase,
            :itself,
            {},
            { label: 'Label' }
          )
        )
      end

      def test_collection_select_with_errors
        dummy = Dummy.new
        dummy.errors.add(:color, :invalid)

        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color" invalid="">
              <div class="haptic-field-container">
                <div class="field_with_errors">
                  <select name="dummy[color]" id="dummy_color">
                    <option value="blue">Blue</option>
                    <option value="green">Green</option>
                  </select>
                </div>
                <div class="haptic-icon error-icon">error</div>
              </div>
              <div class="error-message">Color is invalid.</div>
            </haptic-dropdown-field>
          HTML
          form(dummy).collection_select(
            :color,
            %w[Blue Green],
            :downcase,
            :itself,
            {},
            { show_error_icon: true, show_error_message: true }
          )
        )
      end

      def test_collection_select_dropdown
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="haptic-field-container">
                <haptic-select-dropdown>
                  <input autocomplete="off" type="hidden" name="dummy[color]" id="dummy_color">
                  <div class="toggle haptic-field"></div>
                  <div class="popover">
                    <haptic-option-list>
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </haptic-option-list>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form.collection_select_dropdown(:color, %w[Blue Green], :downcase, :itself)
        )
      end

      def test_collection_select_dropdown_with_field_options
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color" id="field-id" set-valid-on-change="dummy_bar">
              <div class="haptic-field-container">
                <haptic-select-dropdown>
                  <input autocomplete="off" type="hidden" name="dummy[color]" id="dummy_color">
                  <div class="toggle haptic-field"></div>
                  <div class="popover">
                    <haptic-option-list>
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </haptic-option-list>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
                <label is="haptic-label" class="haptic-field-label" for="dummy_color">Color</label>
                <div class="haptic-icon leading-icon">leading_icon</div>
              </div>
              <div class="supporting-text">Supporting text</div>
            </haptic-dropdown-field>
          HTML
          form.collection_select_dropdown(
            :color,
            %w[Blue Green],
            :downcase,
            :itself,
            {},
            {
              field_id: 'field-id',
              label: true,
              leading_icon: 'leading_icon',
              set_valid_on_change: :bar,
              supporting_text: 'Supporting text'
            }
          )
        )
      end

      def test_collection_select_dropdown_with_custom_label
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="haptic-field-container">
                <haptic-select-dropdown>
                  <input autocomplete="off" type="hidden" name="dummy[color]" id="dummy_color">
                  <div class="toggle haptic-field"></div>
                  <div class="popover">
                    <haptic-option-list>
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </haptic-option-list>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
                <label is="haptic-label" class="haptic-field-label" for="dummy_color">Label</label>
              </div>
            </haptic-dropdown-field>
          HTML
          form.collection_select_dropdown(
            :color,
            %w[Blue Green],
            :downcase,
            :itself,
            {},
            { label: 'Label' }
          )
        )
      end

      def test_collection_select_dropdown_with_errors
        dummy = Dummy.new
        dummy.errors.add(:color, :invalid)

        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color" invalid="">
              <div class="haptic-field-container">
                <haptic-select-dropdown>
                  <input autocomplete="off" type="hidden" name="dummy[color]" id="dummy_color">
                  <div class="toggle haptic-field"></div>
                  <div class="popover">
                    <haptic-option-list>
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </haptic-option-list>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
                <div class="haptic-icon error-icon">error</div>
              </div>
              <div class="error-message">Color is invalid.</div>
            </haptic-dropdown-field>
          HTML
          form(dummy).collection_select_dropdown(
            :color,
            %w[Blue Green],
            :downcase,
            :itself,
            {},
            { show_error_icon: true, show_error_message: true }
          )
        )
      end

      def test_collection_select_dropdown_including_blank
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="haptic-field-container">
                <haptic-select-dropdown>
                  <input autocomplete="off" type="hidden" name="dummy[color]" id="dummy_color">
                  <div class="toggle haptic-field"></div>
                  <div class="popover">
                    <haptic-option-list>
                      <haptic-option value="" checked="checked"></haptic-option>
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </haptic-option-list>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form.collection_select_dropdown(
            :color,
            %w[Blue Green],
            :downcase,
            :itself,
            { include_blank: true }
          )
        )
      end

      def test_date_field
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_date">
              <div class="haptic-field-container">
                <input is="haptic-input" type="date" name="dummy[date]" id="dummy_date">
                <div class="haptic-icon trailing-icon">calendar_today</div>
              </div>
            </haptic-text-field>
          HTML
          form.date_field(:date)
        )
      end

      def test_date_field_with_field_options
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_date" id="field-id" set-valid-on-change="dummy_bar">
              <div class="haptic-field-container">
                <input is="haptic-input" type="date" name="dummy[date]" id="dummy_date">
                <label is="haptic-label" class="haptic-field-label" for="dummy_date">Date</label>
                <div class="haptic-icon leading-icon">leading_icon</div>
                <div class="haptic-icon trailing-icon">calendar_today</div>
              </div>
              <div class="supporting-text">Supporting text</div>
            </haptic-text-field>
          HTML
          form.date_field(
            :date,
            field_id: 'field-id',
            label: true,
            leading_icon: 'leading_icon',
            supporting_text: 'Supporting text',
            set_valid_on_change: :bar
          )
        )
      end

      def test_date_field_with_custom_label
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_date">
              <div class="haptic-field-container">
                <input is="haptic-input" type="date" name="dummy[date]" id="dummy_date">
                <label is="haptic-label" class="haptic-field-label" for="dummy_date">Label</label>
                <div class="haptic-icon trailing-icon">calendar_today</div>
              </div>
            </haptic-text-field>
          HTML
          form.date_field(:date, label: 'Label')
        )
      end

      def test_date_field_with_errors
        dummy = Dummy.new
        dummy.errors.add(:date, :invalid)

        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_date" invalid="">
              <div class="haptic-field-container">
                <div class="field_with_errors">
                  <input is="haptic-input" type="date" name="dummy[date]" id="dummy_date">
                </div>
                <div class="haptic-icon error-icon">error</div>
                <div class="haptic-icon trailing-icon">calendar_today</div>
              </div>
              <div class="error-message">Date is invalid.</div>
            </haptic-text-field>
          HTML
          form(dummy).date_field(:date, show_error_icon: true, show_error_message: true)
        )
      end

      def test_date_field_on_nil_object
        form = FormBuilder.new(:dummy, nil, self, {})
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_date">
              <div class="haptic-field-container">
                <input is="haptic-input" type="date" name="dummy[date]" id="dummy_date">
                <div class="haptic-icon trailing-icon">calendar_today</div>
              </div>
            </haptic-text-field>
          HTML
          form.date_field(:date)
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
          form.dropdown_field
        )
      end

      def test_dropdown_field_with_label
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field>
              <div class="haptic-field-container">
                <haptic-dialog-dropdown>
                  <div class="backdrop"></div>
                </haptic-dialog-dropdown>
                <label class="haptic-field-label">Label</label>
              </div>
            </haptic-dropdown-field>
          HTML
          form.dropdown_field(label: 'Label')
        )
      end

      def test_dropdown_field_on_label_true
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
          form.dropdown_field(label: true)
        )
      end

      def test_dropdown_field_with_block
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field>
              <div class="haptic-field-container">
                <haptic-dialog-dropdown>
                  <button class="toggle haptic-field" type="button">Text</button>
                  <div class="popover"></div>
                  <div class="backdrop"></div>
                </haptic-dialog-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form.dropdown_field do |dropdown|
            dropdown.toggle('Text') + dropdown.popover
          end
        )
      end

      def test_error_messages_on_valid_attribute
        assert_nil(form.error_messages(:color))
      end

      def test_error_messages_on_invalid_attribute
        dummy = Dummy.new
        dummy.errors.add(:color, :invalid)

        assert_dom_equal(
          <<~HTML,
            <div class="error">Color is invalid.</div>
          HTML
          form(dummy).error_messages(:color)
        )
      end

      def test_error_message_on_nil_object
        form = FormBuilder.new(:dummy, nil, self, {})
        assert_nil(form.error_messages(:color))
      end

      def test_select
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="haptic-field-container">
                <select is="haptic-select" name="dummy[color]" id="dummy_color">
                  <option value="blue">Blue</option>
                  <option value="green">Green</option>
                </select>
              </div>
            </haptic-dropdown-field>
          HTML
          form.select(:color, [%w[Blue blue], %w[Green green]])
        )
      end

      def test_select_dropdown
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="haptic-field-container">
                <haptic-select-dropdown>
                  <input autocomplete="off" type="hidden" name="dummy[color]" id="dummy_color">
                  <div class="toggle haptic-field"></div>
                  <div class="popover">
                    <haptic-option-list>
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </haptic-option-list>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form.select_dropdown(:color, [%w[Blue blue], %w[Green green]])
        )
      end

      def test_select_dropdown_on_choices_as_hash
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="haptic-field-container">
                <haptic-select-dropdown>
                  <input autocomplete="off" type="hidden" name="dummy[color]" id="dummy_color">
                  <div class="toggle haptic-field"></div>
                  <div class="popover">
                    <haptic-option-list>
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </haptic-option-list>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form.select_dropdown(:color, { 'Blue' => 'blue', 'Green' => 'green' })
        )
      end

      def test_select_dropdown_on_nil_choices
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="haptic-field-container">
                <haptic-select-dropdown>
                  <input autocomplete="off" type="hidden" name="dummy[color]" id="dummy_color">
                  <div class="toggle haptic-field"></div>
                  <div class="popover">
                    <haptic-option-list></haptic-option-list>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form.select_dropdown(:color, nil)
        )
      end

      def test_select_dropdown_with_block
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="haptic-field-container">
                <haptic-select-dropdown>
                  <input autocomplete="off" type="hidden" name="dummy[color]" id="dummy_color">
                  <div class="toggle haptic-field"></div>
                  <div class="popover">
                    <haptic-option-list>
                      <haptic-option value="blue" checked="checked">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </haptic-option-list>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form.select_dropdown(:color) do
            haptic_option_tag('Blue', value: 'blue', checked: true) +
              haptic_option_tag('Green', value: 'green')
          end
        )
      end

      def test_with_field_options
        form = self.form
        assert_nil(
          form.with_field_options(data: { foo: 'bar' }) do
            assert_dom_equal(
              <<~HTML,
                <input is="haptic-input" type="text" name="dummy[name]" id="dummy_name"
                      data-foo="bar">
              HTML
              form.text_field(:name)
            )
          end
        )
      end

      def test_with_field_options_without_block
        assert_nil(form.with_field_options(data: { foo: 'bar' }))
      end

      def test_haptic_text_field_for
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_name" id="field-id">
              <div class="haptic-field-container">
                <input is="haptic-input" type="text" name="dummy[name]" id="dummy_name">
              </div>
            </haptic-text-field>
          HTML
          form.text_field(:name, field_id: 'field-id')
        )
      end

      def test_haptic_text_field_for_on_namespace
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="foo_dummy_name" id="field-id">
              <div class="haptic-field-container">
                <input is="haptic-input" type="text" name="dummy[name]" id="foo_dummy_name">
              </div>
            </haptic-text-field>
          HTML
          form(namespace: :foo).text_field(:name, field_id: 'field-id')
        )
      end

      def test_haptic_text_field_for_on_index
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_0_name" id="field-id">
              <div class="haptic-field-container">
                <input is="haptic-input" type="text" name="dummy[0][name]" id="dummy_0_name">
              </div>
            </haptic-text-field>
          HTML
          form(index: 0).text_field(:name, field_id: 'field-id')
        )
      end

      def test_haptic_text_field_for_on_rails6
        with_rails6_form_builder do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_name" id="field-id">
                <div class="haptic-field-container">
                  <input is="haptic-input" type="text" name="dummy[name]" id="dummy_name">
                </div>
              </haptic-text-field>
            HTML
            form.text_field(:name, field_id: 'field-id')
          )
        end
      end

      def test_haptic_text_field_for_on_rails6_and_namespace
        with_rails6_form_builder do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="foo_dummy_name" id="field-id">
                <div class="haptic-field-container">
                  <input is="haptic-input" type="text" name="dummy[name]" id="foo_dummy_name">
                </div>
              </haptic-text-field>
            HTML
            form(namespace: :foo).text_field(:name, field_id: 'field-id')
          )
        end
      end

      def test_haptic_text_field_for_on_rails6_and_index
        with_rails6_form_builder do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_0_name" id="field-id">
                <div class="haptic-field-container">
                  <input is="haptic-input" type="text" name="dummy[0][name]" id="dummy_0_name">
                </div>
              </haptic-text-field>
            HTML
            form(index: 0).text_field(:name, field_id: 'field-id')
          )
        end
      end

      private

      def form(object = nil, options = {})
        object, options = nil, object if object.is_a?(Hash)
        object ||= Dummy.new

        FormBuilder.new(object.class.model_name.param_key, object, self, options)
      end

      def with_rails6_form_builder(&block)
        FormBuilder.stub_any_instance(
          :respond_to?,
          lambda do |arg1, arg2 = nil|
            return false if arg1 == :field_id

            FormBuilder.respond_to?(arg1, arg2)
          end,
          &block
        )
      end
    end
  end
end
