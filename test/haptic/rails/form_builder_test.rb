# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class FormBuilderTest < ActionView::TestCase
      include Haptic::Rails::Helpers::DropdownTagHelper
      include Haptic::Rails::Helpers::FieldTagHelper
      include Haptic::Rails::Helpers::FormOptionsHelper
      include Haptic::Rails::Helpers::IconTagHelper

      {
        email_field: 'email',
        file_field: 'file',
        number_field: 'number',
        password_field: 'password',
        phone_field: 'tel',
        search_field: 'search',
        telephone_field: 'tel',
        text_field: 'text'
      }.each do |method, type|
        define_method("test_#{method}") do
          assert_dom_equal(
            <<~HTML,
              <input is="haptic-input" type="#{type}" name="dummy[name]" id="dummy_name">
            HTML
            form.send(method, :name)
          )
        end

        define_method("test_#{method}_with_field_options") do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_name" id="field-id" set-valid-on-change="dummy_bar">
                <div class="field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[name]" id="dummy_name">
                  <label is="haptic-label" class="field-label" for="dummy_name">Name</label>
                  <button type="button" class="clear-button">
                    <div class="haptic-icon">close</div>
                  </button>
                  <div class="haptic-icon leading-icon">leading_icon</div>
                  <div class="haptic-icon trailing-icon">trailing_icon</div>
                </div>
                <div class="supporting-text">Supporting text</div>
              </haptic-text-field>
            HTML
            form.send(
              method,
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

        define_method("test_#{method}_with_label_as_string") do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_name">
                <div class="field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[name]" id="dummy_name">
                  <label is="haptic-label" class="field-label" for="dummy_name">Label</label>
                </div>
              </haptic-text-field>
            HTML
            form.send(method, :name, label: 'Label')
          )
        end

        define_method("test_#{method}_with_errors") do
          dummy = Dummy.new
          dummy.errors.add(:name, :invalid)

          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_name" invalid="">
                <div class="field-container">
                  <div class="field_with_errors">
                    <input is="haptic-input" type="#{type}" name="dummy[name]" id="dummy_name">
                  </div>
                  <div class="haptic-icon error-icon">error</div>
                </div>
                <div class="error-message">Name is invalid.</div>
              </haptic-text-field>
            HTML
            form(dummy).send(
              method,
              :name,
              show_error_icon: true,
              show_error_message: true
            )
          )
        end

        define_method("test_#{method}_on_nil_object") do
          form = FormBuilder.new(:dummy, nil, self, {})
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_name">
                <div class="field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[name]" id="dummy_name">
                  <label is="haptic-label" class="field-label" for="dummy_name">Name</label>
                </div>
              </haptic-text-field>
            HTML
            form.send(method, :name, label: true)
          )
        end
      end

      def test_color_field
        assert_dom_equal(
          <<~HTML,
            <input is="haptic-input" type="color" name="dummy[color]" value="#000000"
              id="dummy_color">
          HTML
          form.color_field(:color)
        )
      end

      def test_color_field_with_field_options
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_color" id="field-id" set-valid-on-change="dummy_bar">
              <div class="field-container">
                <input is="haptic-input" type="color" name="dummy[color]" value="#000000"
                  id="dummy_color">
                <label is="haptic-label" class="field-label" for="dummy_color">Color</label>
                <button type="button" class="clear-button">
                  <div class="haptic-icon">close</div>
                </button>
                <div class="haptic-icon leading-icon">leading_icon</div>
                <div class="haptic-icon trailing-icon">trailing_icon</div>
              </div>
              <div class="supporting-text">Supporting text</div>
            </haptic-text-field>
          HTML
          form.color_field(
            :color,
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

      def test_color_field_with_label_string
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_color">
              <div class="field-container">
                <input is="haptic-input" type="color" name="dummy[color]" value="#000000"
                  id="dummy_color">
                <label is="haptic-label" class="field-label" for="dummy_color">Label</label>
              </div>
            </haptic-text-field>
          HTML
          form.color_field(:color, label: 'Label')
        )
      end

      def test_color_field_with_errors
        dummy = Dummy.new
        dummy.errors.add(:color, :invalid)

        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_color" invalid="">
              <div class="field-container">
                <div class="field_with_errors">
                  <input is="haptic-input" type="color" name="dummy[color]" value="#000000"
                    id="dummy_color">
                </div>
                <div class="haptic-icon error-icon">error</div>
              </div>
              <div class="error-message">Color is invalid.</div>
            </haptic-text-field>
          HTML
          form(dummy).color_field(
            :color,
            show_error_icon: true,
            show_error_message: true
          )
        )
      end

      def test_color_field_on_nil_object
        form = FormBuilder.new(:dummy, nil, self, {})
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_color">
              <div class="field-container">
                <input is="haptic-input" type="color" name="dummy[color]" value="#000000"
                  id="dummy_color">
                <label is="haptic-label" class="field-label" for="dummy_color">Color</label>
              </div>
            </haptic-text-field>
          HTML
          form.color_field(:color, label: true)
        )
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
              <div class="field-container">
                <textarea is="haptic-textarea" name="dummy[name]" id="dummy_name"></textarea>
                <label is="haptic-label" class="field-label" for="dummy_name">Name</label>
                <button type="button" class="clear-button">
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

      def test_text_area_with_label_as_string
        assert_dom_equal(
          <<~HTML,
            <haptic-text-field for="dummy_name">
              <div class="field-container">
                <textarea is="haptic-textarea" name="dummy[name]" id="dummy_name"></textarea>
                <label is="haptic-label" class="field-label" for="dummy_name">Label</label>
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
              <div class="field-container">
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

      {
        date_field: 'date',
        datetime_field: 'datetime-local',
        datetime_local_field: 'datetime-local',
        month_field: 'month',
        week_field: 'week'
      }.each do |method, type|
        define_method(:"test_#{method}") do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_date">
                <div class="field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[date]" id="dummy_date">
                  <div class="haptic-icon trailing-icon">calendar_today</div>
                </div>
              </haptic-text-field>
            HTML
            form.send(method, :date)
          )
        end

        define_method(:"test_#{method}_with_field_options") do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_date" id="field-id" set-valid-on-change="dummy_bar">
                <div class="field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[date]" id="dummy_date">
                  <label is="haptic-label" class="field-label" for="dummy_date">Date</label>
                  <div class="haptic-icon leading-icon">leading_icon</div>
                  <div class="haptic-icon trailing-icon">calendar_today</div>
                </div>
                <div class="supporting-text">Supporting text</div>
              </haptic-text-field>
            HTML
            form.send(
              method,
              :date,
              field_id: 'field-id',
              label: true,
              leading_icon: 'leading_icon',
              supporting_text: 'Supporting text',
              set_valid_on_change: :bar
            )
          )
        end

        define_method(:"test_#{method}_with_label_as_string") do
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_date">
                <div class="field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[date]" id="dummy_date">
                  <label is="haptic-label" class="field-label" for="dummy_date">Label</label>
                  <div class="haptic-icon trailing-icon">calendar_today</div>
                </div>
              </haptic-text-field>
            HTML
            form.send(method, :date, label: 'Label')
          )
        end

        define_method(:"test_#{method}_with_errors") do
          dummy = Dummy.new
          dummy.errors.add(:date, :invalid)

          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_date" invalid="">
                <div class="field-container">
                  <div class="field_with_errors">
                    <input is="haptic-input" type="#{type}" name="dummy[date]" id="dummy_date">
                  </div>
                  <div class="haptic-icon error-icon">error</div>
                  <div class="haptic-icon trailing-icon">calendar_today</div>
                </div>
                <div class="error-message">Date is invalid.</div>
              </haptic-text-field>
            HTML
            form(dummy).send(method, :date, show_error_icon: true, show_error_message: true)
          )
        end

        define_method(:"test_#{method}_on_nil_object") do
          form = FormBuilder.new(:dummy, nil, self, {})
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field for="dummy_date">
                <div class="field-container">
                  <input is="haptic-input" type="#{type}" name="dummy[date]" id="dummy_date">
                  <div class="haptic-icon trailing-icon">calendar_today</div>
                </div>
              </haptic-text-field>
            HTML
            form.send(method, :date)
          )
        end
      end

      def test_chips
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="dummy[color][]" value="" autocomplete="off">
            <haptic-chip>
              <input is="haptic-input" type="checkbox" value="blue" name="dummy[color][]"
                id="dummy_color_blue">
              <label is="haptic-label" for="dummy_color_blue">Blue</label>
            </haptic-chip>
            <haptic-chip>
              <input is="haptic-input" type="checkbox" value="green" name="dummy[color][]"
                id="dummy_color_green">
              <label is="haptic-label" for="dummy_color_green">Green</label>
            </haptic-chip>
          HTML
          form.chips(:color, [%w[Blue blue], %w[Green green]])
        )
      end

      def test_chips_on_choices_as_hash
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="dummy[color][]" value="" autocomplete="off">
            <haptic-chip>
              <input is="haptic-input" type="checkbox" value="blue" name="dummy[color][]"
                id="dummy_color_blue">
              <label is="haptic-label" for="dummy_color_blue">Blue</label>
            </haptic-chip>
            <haptic-chip>
              <input is="haptic-input" type="checkbox" value="green" name="dummy[color][]"
                id="dummy_color_green">
              <label is="haptic-label" for="dummy_color_green">Green</label>
            </haptic-chip>
          HTML
          form.chips(:color, { 'Blue' => 'blue', 'Green' => 'green' })
        )
      end

      def test_chips_with_block
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="dummy[color][]" value="" autocomplete="off">
            <haptic-chip>
              <input type="checkbox" value="blue" name="dummy[color][]" id="dummy_color_blue"
                checked="checked">
              <label for="dummy_color_blue">Blue</label>
            </haptic-chip>
            <haptic-chip>
              <input type="checkbox" value="green" name="dummy[color][]" id="dummy_color_green">
              <label for="dummy_color_green">Green</label>
            </haptic-chip>
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

      def test_list_on_inverted_items
        assert_dom_equal(
          <<~HTML,
            <haptic-list>
              <input type="hidden" name="dummy[color]" value="" autocomplete="off">
              <haptic-list-item class="inverted">
                <input is="haptic-input" type="radio" value="blue" name="dummy[color]"
                  id="dummy_color_blue">
                <label is="haptic-label" for="dummy_color_blue">Blue</label>
              </haptic-list-item>
              <haptic-list-item class="inverted">
                <input is="haptic-input" type="radio" value="green" name="dummy[color]"
                  id="dummy_color_green">
                <label is="haptic-label" for="dummy_color_green">Green</label>
              </haptic-list-item>
            </haptic-list>
          HTML
          form.list(:color, [%w[Blue blue], %w[Green green]], inverted: true)
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
              <haptic-button-segment>
                <input is="haptic-input" type="radio" value="blue" name="dummy[color]"
                  id="dummy_color_blue">
                <label is="haptic-label" for="dummy_color_blue">Blue</label>
              </haptic-button-segment>
              <haptic-button-segment>
                <input is="haptic-input" type="radio" value="green" name="dummy[color]"
                  id="dummy_color_green">
                <label is="haptic-label" for="dummy_color_green">Green</label>
              </haptic-button-segment>
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
              <haptic-button-segment>
                <input is="haptic-input" type="radio" value="blue" name="dummy[color]"
                  id="dummy_color_blue">
                <label is="haptic-label" for="dummy_color_blue">Blue</label>
              </haptic-button-segment>
              <haptic-button-segment>
                <input is="haptic-input" type="radio" value="green" name="dummy[color]"
                  id="dummy_color_green">
                <label is="haptic-label" for="dummy_color_green">Green</label>
              </haptic-button-segment>
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
              <haptic-button-segment>
                <input type="radio" value="blue" name="dummy[color]" id="dummy_color_blue"
                  checked="checked">
                <label for="dummy_color_blue">Blue</label>
              </haptic-button-segment>
              <haptic-button-segment>
                <input type="radio" value="green" name="dummy[color]" id="dummy_color_green">
                <label for="dummy_color_green">Green</label>
              </haptic-button-segment>
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
            <haptic-chip>
              <input is="haptic-input" type="checkbox" value="blue" name="dummy[color][]"
                id="dummy_color_blue">
              <label is="haptic-label" for="dummy_color_blue">Blue</label>
            </haptic-chip>
            <haptic-chip>
              <input is="haptic-input" type="checkbox" value="green" name="dummy[color][]"
                id="dummy_color_green">
              <label is="haptic-label" for="dummy_color_green">Green</label>
            </haptic-chip>
          HTML
          form.collection_chips(:color, %w[Blue Green], :downcase, :itself)
        )
      end

      def test_collection_chips_with_block
        assert_dom_equal(
          <<~HTML,
            <input type="hidden" name="dummy[color][]" value="" autocomplete="off">
            <haptic-chip>
              <input type="checkbox" value="blue" name="dummy[color][]" id="dummy_color_blue"
                checked="checked">
              <label for="dummy_color_blue">Blue</label>
            </haptic-chip>
            <haptic-chip>
              <input type="checkbox" value="green" name="dummy[color][]" id="dummy_color_green">
              <label for="dummy_color_green">Green</label>
            </haptic-chip>
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

      def test_collection_list_on_inverted_items
        assert_dom_equal(
          <<~HTML,
            <haptic-list>
              <input type="hidden" name="dummy[color]" value="" autocomplete="off">
              <haptic-list-item class="inverted">
                <input is="haptic-input" type="radio" value="blue" name="dummy[color]"
                  id="dummy_color_blue">
                <label is="haptic-label" for="dummy_color_blue">Blue</label>
              </haptic-list-item>
              <haptic-list-item class="inverted">
                <input is="haptic-input" type="radio" value="green" name="dummy[color]"
                  id="dummy_color_green">
                <label is="haptic-label" for="dummy_color_green">Green</label>
              </haptic-list-item>
            </haptic-list>
          HTML
          form.collection_list(:color, %w[Blue Green], :downcase, :itself, inverted: true)
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
              <haptic-button-segment>
                <input is="haptic-input" type="radio" value="blue" name="dummy[color]"
                  id="dummy_color_blue">
                <label is="haptic-label" for="dummy_color_blue">Blue</label>
              </haptic-button-segment>
              <haptic-button-segment>
                <input is="haptic-input" type="radio" value="green" name="dummy[color]"
                  id="dummy_color_green">
                <label is="haptic-label" for="dummy_color_green">Green</label>
              </haptic-button-segment>
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
              <haptic-button-segment>
                <input is="haptic-input" type="radio" value="blue" name="dummy[color]"
                  id="dummy_color_blue" checked="checked">
                <label is="haptic-label" for="dummy_color_blue">Blue</label>
              </haptic-button-segment>
              <haptic-button-segment>
                <input is="haptic-input" type="radio" value="green" name="dummy[color]"
                  id="dummy_color_green">
                <label is="haptic-label" for="dummy_color_green">Green</label>
              </haptic-button-segment>
            </haptic-segmented-button>
          HTML
          form.collection_segmented_button(:color, %w[Blue Green], :downcase, :itself) do |b|
            b.radio_button(checked: b.value == 'blue') + b.label
          end
        )
      end

      def test_collection_select
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="field-container">
                <select is="haptic-select" name="dummy[color]" id="dummy_color">
                  <option value="blue">Blue</option>
                  <option value="green">Green</option>
                </select>
              </div>
            </haptic-dropdown-field>
          HTML
          form.collection_select(:color, %w[Blue Green], :downcase, :itself)
        )
      end

      def test_collection_select_with_custom_class
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="field-container">
                <select is="custom-select" name="dummy[color]" id="dummy_color">
                  <option value="blue">Blue</option>
                  <option value="green">Green</option>
                </select>
              </div>
            </haptic-dropdown-field>
          HTML
          form.collection_select(
            :color,
            %w[Blue Green],
            :downcase,
            :itself,
            {},
            { is: 'custom-select' }
          )
        )
      end

      def test_collection_select_with_field_options
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color" id="field-id" set-valid-on-change="dummy_bar">
              <div class="field-container">
                <select is="haptic-select" name="dummy[color]" id="dummy_color">
                  <option value="blue">Blue</option>
                  <option value="green">Green</option>
                </select>
                <label is="haptic-label" class="field-label" for="dummy_color">Color</label>
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

      def test_collection_select_with_label_as_string
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="field-container">
                <select is="haptic-select" name="dummy[color]" id="dummy_color">
                  <option value="blue">Blue</option>
                  <option value="green">Green</option>
                </select>
                <label is="haptic-label" class="field-label" for="dummy_color">Label</label>
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
              <div class="field-container">
                <div class="field_with_errors">
                  <select is="haptic-select" name="dummy[color]" id="dummy_color">
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
              <div class="field-container">
                <haptic-select-dropdown>
                  <input type="text" name="dummy[color]" id="dummy_color">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container">
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </div>
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
              <div class="field-container">
                <haptic-select-dropdown>
                  <input type="text" name="dummy[color]" id="dummy_color">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container">
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </div>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
                <label is="haptic-label" class="field-label" for="dummy_color">Color</label>
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

      def test_collection_select_dropdown_with_label_as_string
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="field-container">
                <haptic-select-dropdown>
                  <input type="text" name="dummy[color]" id="dummy_color">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container">
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </div>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
                <label is="haptic-label" class="field-label" for="dummy_color">Label</label>
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
              <div class="field-container">
                <haptic-select-dropdown>
                  <input type="text" name="dummy[color]" id="dummy_color">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container">
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </div>
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

      def test_collection_select_dropdown_with_include_blank
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="field-container">
                <haptic-select-dropdown>
                  <input type="text" name="dummy[color]" id="dummy_color">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container">
                      <haptic-option value="" checked="checked"></haptic-option>
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </div>
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

      def test_collection_select_dropdown_with_disabled_option
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="field-container">
                <haptic-select-dropdown>
                  <input type="text" name="dummy[color]" id="dummy_color">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container">
                      <haptic-option value="blue" disabled="disabled">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </div>
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
            { disabled: 'blue' }
          )
        )
      end

      def test_collection_select_dropdown_with_multiple_disabled_options
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="field-container">
                <haptic-select-dropdown>
                  <input type="text" name="dummy[color]" id="dummy_color">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container">
                      <haptic-option value="blue" disabled="disabled">Blue</haptic-option>
                      <haptic-option value="green" disabled="disabled">Green</haptic-option>
                    </div>
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
            { disabled: %w[blue green] }
          )
        )
      end

      def test_disabled_collection_select_dropdown
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="field-container">
                <haptic-select-dropdown>
                  <input type="text" name="dummy[color]" id="dummy_color"
                    disabled="disabled">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container">
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </div>
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
            {},
            { disabled: true }
          )
        )
      end

      def test_dropdown_field
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field>
              <div class="field-container">
                <haptic-dropdown-dialog>
                  <div class="backdrop"></div>
                </haptic-dropdown-dialog>
              </div>
            </haptic-dropdown-field>
          HTML
          form.dropdown_field
        )
      end

      def test_dropdown_field_with_options
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field focus-indicator="focus">
              <div class="field-container">
                <haptic-dropdown-dialog open-to-top>
                  <div class="backdrop"></div>
                </haptic-dropdown-dialog>
                <label class="field-label">Label</label>

              </div>
            </haptic-dropdown-field>
          HTML
          form.dropdown_field(
            focus_indicator: 'focus',
            label: 'Label',
            open_to_top: true
          )
        )
      end

      def test_dropdown_field_with_label_true
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field>
              <div class="field-container">
                <haptic-dropdown-dialog>
                  <div class="backdrop"></div>
                </haptic-dropdown-dialog>
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
              <div class="field-container">
                <haptic-dropdown-dialog>
                  <button class="toggle haptic-field" type="button">Text</button>
                  <div class="popover"></div>
                  <div class="backdrop"></div>
                </haptic-dropdown-dialog>
              </div>
            </haptic-dropdown-field>
          HTML
          form.dropdown_field do |dropdown|
            dropdown.toggle('Text') + dropdown.popover
          end
        )
      end

      def test_dropdown_field_with_block_and_options
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field focus-indicator="focus">
              <div class="field-container">
                <haptic-dropdown-dialog open-to-top>
                  <button class="toggle haptic-field" type="button" data-foo="bar">Text</button>
                  <div class="popover"></div>
                  <div class="backdrop"></div>
                </haptic-dropdown-dialog>
                <label class="field-label">Label</label>
              </div>
            </haptic-dropdown-field>
          HTML
          form.dropdown_field(
            data: { foo: 'bar' },
            focus_indicator: 'focus',
            label: 'Label',
            open_to_top: true
          ) do |dropdown|
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
              <div class="field-container">
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
              <div class="field-container">
                <haptic-select-dropdown>
                  <input type="text" name="dummy[color]" id="dummy_color">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container"></div>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form.select_dropdown(:color, nil)
        )
      end

      def test_select_dropdown_with_choices
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="field-container">
                <haptic-select-dropdown>
                  <input type="text" name="dummy[color]" id="dummy_color">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container">
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </div>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form.select_dropdown(:color, [%w[Blue blue], %w[Green green]])
        )
      end

      def test_select_dropdown_with_choices_as_hash
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="field-container">
                <haptic-select-dropdown>
                  <input type="text" name="dummy[color]" id="dummy_color">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container">
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </div>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form.select_dropdown(:color, { 'Blue' => 'blue', 'Green' => 'green' })
        )
      end

      def test_select_dropdown_with_choices_and_options
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="field-container">
                <haptic-select-dropdown data-foo="bar">
                  <input type="text" name="dummy[color]"
                    required="required">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container">
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </div>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form.select_dropdown(
            :color,
            [%w[Blue blue], %w[Green green]],
            data: { foo: 'bar' },
            id: nil,
            required: true
          )
        )
      end

      def test_select_dropdown_with_block
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="field-container">
                <haptic-select-dropdown>
                  <input type="text" name="dummy[color]" id="dummy_color">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container">
                      <haptic-option value="blue" checked="checked">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </div>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form.select_dropdown(:color) do
            tag.haptic_option('Blue', value: 'blue', checked: true) +
              tag.haptic_option('Green', value: 'green')
          end
        )
      end

      def test_select_dropdown_with_disabled_value
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="field-container">
                <haptic-select-dropdown>
                  <input type="text" name="dummy[color]" id="dummy_color">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container">
                      <haptic-option value="blue" disabled="disabled">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </div>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form.select_dropdown(:color, [%w[Blue blue], %w[Green green]], disabled: 'blue')
        )
      end

      def test_select_dropdown_with_multiple_disabled_values
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="field-container">
                <haptic-select-dropdown>
                  <input type="text" name="dummy[color]" id="dummy_color">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container">
                      <haptic-option value="blue" disabled="disabled">Blue</haptic-option>
                      <haptic-option value="green" disabled="disabled">Green</haptic-option>
                    </div>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form.select_dropdown(
            :color,
            [%w[Blue blue], %w[Green green]],
            disabled: %w[blue green]
          )
        )
      end

      def test_disabled_select_dropdown
        assert_dom_equal(
          <<~HTML,
            <haptic-dropdown-field for="dummy_color">
              <div class="field-container">
                <haptic-select-dropdown>
                  <input type="text" name="dummy[color]" id="dummy_color"
                    disabled="disabled">
                  <button class="toggle haptic-field" type="button"></button>
                  <div class="popover">
                    <div class="scroll-container">
                      <haptic-option value="blue">Blue</haptic-option>
                      <haptic-option value="green">Green</haptic-option>
                    </div>
                  </div>
                  <div class="backdrop"></div>
                </haptic-select-dropdown>
              </div>
            </haptic-dropdown-field>
          HTML
          form.select_dropdown(:color, [%w[Blue blue], %w[Green green]], disabled: true)
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

      def test_fields
        form = self.form
        form.with_field_options(data: { foo: 'bar' }) do
          form.fields(:nested, builder: FormBuilder) do |nested_fields|
            assert_dom_equal(
              <<~HTML,
                <input is="haptic-input", type="text" name="dummy[nested][name]"
                  data-foo="bar"/>
              HTML
              nested_fields.text_field(:name)
            )
          end
        end
      end

      def test_fields_for
        form = self.form
        form.with_field_options(data: { foo: 'bar' }) do
          form.fields_for(:nested, nil, builder: FormBuilder) do |nested_fields|
            assert_dom_equal(
              <<~HTML,
                <input is="haptic-input", type="text" name="dummy[nested][name]"
                  id="dummy_nested_name" data-foo="bar"/>
              HTML
              nested_fields.text_field(:name)
            )
          end
        end
      end

      private

      def form(object = nil, options = {})
        object, options = nil, object if object.is_a?(Hash)
        object ||= Dummy.new

        FormBuilder.new(object.class.model_name.param_key, object, self, options)
      end
    end
  end
end
