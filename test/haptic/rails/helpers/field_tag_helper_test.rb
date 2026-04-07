# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class FieldHelperTest < ActionView::TestCase
        include DropdownTagHelper
        include FieldTagHelper
        include IconTagHelper

        # #haptic_dropdown_field_tag

        def test_haptic_dropdown_field_tag
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-field>
                <div class="field-container"></div>
              </haptic-dropdown-field>
            HTML
            haptic_dropdown_field_tag
          )
        end

        def test_haptic_dropdown_field_tag_with_falsely_option
          [nil, false].each do |value|
            assert_dom_equal(
              <<~HTML,
                <haptic-dropdown-field>
                  <div class="field-container"></div>
                </haptic-dropdown-field>
              HTML
              haptic_dropdown_field_tag(focus_indicator: value)
            )
          end
        end

        def test_haptic_dropdown_field_tag_with_options
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-field focus-indicator="focus" data-foo="bar">
                <div class="field-container">
                  <div class="haptic-icon error-icon">error</div>
                  <div class="haptic-icon leading-icon">leading_icon</div>
                </div>
                <div class="error-message">Error message</div>
                <div class="supporting-text">Helper text</div>
              </haptic-dropdown-field>
            HTML
            haptic_dropdown_field_tag(
              data: { foo: 'bar' },
              error_message: 'Error message',
              focus_indicator: true,
              leading_icon: 'leading_icon',
              show_error_icon: true,
              show_error_message: true,
              supporting_text: 'Helper text'
            )
          )
        end

        def test_haptic_dropdown_field_tag_with_field
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-field>
                <div class="field-container">
                  <haptic-select-dropdown>
                    <div class="backdrop"></div>
                  </haptic-select-dropdown>
                </div>
              </haptic-dropdown-field>
            HTML
            haptic_dropdown_field_tag(haptic_select_dropdown_tag)
          )
        end

        def test_haptic_dropdown_field_tag_with_field_and_options
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-field focus-indicator="focus" data-foo="bar">
                <div class="field-container">
                  <haptic-select-dropdown>
                    <div class="backdrop"></div>
                  </haptic-select-dropdown>
                  <div class="haptic-icon error-icon">error</div>
                  <div class="haptic-icon leading-icon">leading_icon</div>
                </div>
                <div class="error-message">Error message</div>
                <div class="supporting-text">Helper text</div>
              </haptic-dropdown-field>
            HTML
            haptic_dropdown_field_tag(
              haptic_select_dropdown_tag,
              data: { foo: 'bar' },
              error_message: 'Error message',
              focus_indicator: true,
              leading_icon: 'leading_icon',
              show_error_icon: true,
              show_error_message: true,
              supporting_text: 'Helper text'
            )
          )
        end

        def test_haptic_dropdown_field_tag_with_field_and_label
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-field>
                <div class="field-container">
                  <haptic-select-dropdown>
                    <div class="backdrop"></div>
                  </haptic-select-dropdown>
                  <label class="field-label">Label</label>
                </div>
              </haptic-dropdown-field>
            HTML
            haptic_dropdown_field_tag(haptic_select_dropdown_tag, 'Label')
          )
        end

        def test_haptic_dropdown_field_tag_with_field_and_label_as_tag
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-field>
                <div class="field-container">
                  <haptic-select-dropdown>
                    <div class="backdrop"></div>
                  </haptic-select-dropdown>
                  <label>Label</label>
                </div>
              </haptic-dropdown-field>
            HTML
            haptic_dropdown_field_tag(
              haptic_select_dropdown_tag,
              tag.label('Label')
            )
          )
        end

        def test_haptic_dropdown_field_tag_with_field_label_and_options
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-field animated-label focus-indicator="focus" data-foo="bar">
                <div class="field-container">
                  <haptic-select-dropdown>
                    <div class="backdrop"></div>
                  </haptic-select-dropdown>
                  <label class="field-label">Label</label>
                  <div class="haptic-icon error-icon">error</div>
                  <div class="haptic-icon leading-icon">leading_icon</div>
                </div>
                <div class="error-message">Error message</div>
                <div class="supporting-text">Helper text</div>
              </haptic-dropdown-field>
            HTML
            haptic_dropdown_field_tag(
              haptic_select_dropdown_tag,
              'Label',
              animated_label: true,
              data: { foo: 'bar' },
              error_message: 'Error message',
              focus_indicator: true,
              leading_icon: 'leading_icon',
              show_error_icon: true,
              show_error_message: true,
              supporting_text: 'Helper text'
            )
          )
        end

        def test_haptic_dropdown_field_tag_with_block
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-field>
                <div class="field-container">
                  <haptic-select-dropdown>
                    <div class="backdrop"></div>
                  </haptic-select-dropdown>
                </div>
              </haptic-dropdown-field>
            HTML
            haptic_dropdown_field_tag do
              haptic_select_dropdown_tag
            end
          )
        end

        def test_haptic_dropdown_field_tag_with_block_and_options
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-field focus-indicator="focus" data-foo="bar">
                <div class="field-container">
                  <haptic-select-dropdown>
                    <div class="backdrop"></div>
                  </haptic-select-dropdown>
                  <div class="haptic-icon error-icon">error</div>
                  <div class="haptic-icon leading-icon">leading_icon</div>
                </div>
                <div class="error-message">Error message</div>
                <div class="supporting-text">Helper text</div>
              </haptic-dropdown-field>
            HTML
            haptic_dropdown_field_tag(
              data: { foo: 'bar' },
              error_message: 'Error message',
              focus_indicator: true,
              leading_icon: 'leading_icon',
              show_error_icon: true,
              show_error_message: true,
              supporting_text: 'Helper text'
            ) do
              haptic_select_dropdown_tag
            end
          )
        end

        def test_haptic_dropdown_field_tag_with_block_and_label
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-field>
                <div class="field-container">
                  <haptic-select-dropdown>
                    <div class="backdrop"></div>
                  </haptic-select-dropdown>
                  <label class="field-label">Label</label>
                </div>
              </haptic-dropdown-field>
            HTML
            haptic_dropdown_field_tag('Label') do
              haptic_select_dropdown_tag
            end
          )
        end

        def test_haptic_dropdown_field_tag_with_block_label_and_options
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-field animated-label focus-indicator="focus" data-foo="bar">
                <div class="field-container">
                  <haptic-select-dropdown>
                    <div class="backdrop"></div>
                  </haptic-select-dropdown>
                  <label class="field-label">Label</label>
                  <div class="haptic-icon error-icon">error</div>
                  <div class="haptic-icon leading-icon">leading_icon</div>
                </div>
                <div class="error-message">Error message</div>
                <div class="supporting-text">Helper text</div>
              </haptic-dropdown-field>
            HTML
            haptic_dropdown_field_tag(
              'Label',
              animated_label: true,
              data: { foo: 'bar' },
              error_message: 'Error message',
              focus_indicator: true,
              leading_icon: 'leading_icon',
              show_error_icon: true,
              show_error_message: true,
              supporting_text: 'Helper text'
            ) do
              haptic_select_dropdown_tag
            end
          )
        end

        # #haptic_text_field_tag

        def test_haptic_text_field_tag
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container"></div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag
          )
        end

        def test_haptic_text_field_tag_with_falsely_option
          [nil, false].each do |value|
            assert_dom_equal(
              <<~HTML,
                <haptic-text-field>
                  <div class="field-container"></div>
                </haptic-text-field>
              HTML
              haptic_text_field_tag(focus_indicator: value)
            )
          end
        end

        def test_haptic_text_field_tag_with_options
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field focus-indicator="focus" data-foo="bar">
                <div class="field-container">
                  <button type="button" class="clear-button">
                    <div class="haptic-icon">close</div>
                  </button>
                  <div class="haptic-icon error-icon">error</div>
                  <div class="haptic-icon leading-icon">leading_icon</div>
                  <div class="haptic-icon trailing-icon">trailing_icon</div>
                </div>
                <div class="error-message">Error message</div>
                <div class="supporting-text">Helper text</div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(
              clear_button: true,
              data: { foo: 'bar' },
              error_message: 'Error message',
              focus_indicator: true,
              leading_icon: 'leading_icon',
              show_error_icon: true,
              show_error_message: true,
              supporting_text: 'Helper text',
              trailing_icon: 'trailing_icon'
            )
          )
        end

        def test_haptic_text_field_tag_with_field
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  <input type="text" name="name">
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(tag.input(type: 'text', name: 'name'))
          )
        end

        def test_haptic_text_field_tag_with_field_and_options
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field focus-indicator="focus" data-foo="bar">
                <div class="field-container">
                  <input type="text" name="name">
                  <button type="button" class="clear-button">
                    <div class="haptic-icon">close</div>
                  </button>
                  <div class="haptic-icon error-icon">error</div>
                  <div class="haptic-icon leading-icon">leading_icon</div>
                  <div class="haptic-icon trailing-icon">trailing_icon</div>
                </div>
                <div class="error-message">Error message</div>
                <div class="supporting-text">Helper text</div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(
              tag.input(type: 'text', name: 'name'),
              clear_button: true,
              data: { foo: 'bar' },
              error_message: 'Error message',
              focus_indicator: true,
              leading_icon: 'leading_icon',
              show_error_icon: true,
              show_error_message: true,
              supporting_text: 'Helper text',
              trailing_icon: 'trailing_icon'
            )
          )
        end

        def test_haptic_text_field_tag_with_field_and_label
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  <input type="text" name="name">
                  <label class="field-label">Label</label>
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(
              tag.input(type: 'text', name: 'name'),
              'Label'
            )
          )
        end

        def test_haptic_text_field_tag_with_field_and_label_as_tag
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  <input type="text" name="name">
                  <label>Label</label>
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(
              tag.input(type: 'text', name: 'name'),
              tag.label('Label')
            )
          )
        end

        def test_haptic_text_field_tag_with_field_label_and_options
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field animated-label focus-indicator="focus" data-foo="bar">
                <div class="field-container">
                  <input name="name" type="text">
                  <label class="field-label">Label</label>
                  <button type="button" class="clear-button">
                    <div class="haptic-icon">close</div>
                  </button>
                  <div class="haptic-icon error-icon">error</div>
                  <div class="haptic-icon leading-icon">leading_icon</div>
                  <div class="haptic-icon trailing-icon">trailing_icon</div>
                </div>
                <div class="error-message">Error message</div>
                <div class="supporting-text">Helper text</div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(
              tag.input(type: 'text', name: 'name'),
              'Label',
              animated_label: true,
              clear_button: true,
              data: { foo: 'bar' },
              error_message: 'Error message',
              focus_indicator: true,
              leading_icon: 'leading_icon',
              show_error_icon: true,
              show_error_message: true,
              supporting_text: 'Helper text',
              trailing_icon: 'trailing_icon'
            )
          )
        end

        def test_haptic_text_field_tag_with_block
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  <input type="text" name="name">
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag do
              tag.input(type: 'text', name: 'name')
            end
          )
        end

        def test_haptic_text_field_tag_with_block_and_options
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field focus-indicator="focus" data-foo="bar">
                <div class="field-container">
                  <input type="text" name="name">
                  <button type="button" class="clear-button">
                    <div class="haptic-icon">close</div>
                  </button>
                  <div class="haptic-icon error-icon">error</div>
                  <div class="haptic-icon leading-icon">leading_icon</div>
                  <div class="haptic-icon trailing-icon">trailing_icon</div>
                </div>
                <div class="error-message">Error message</div>
                <div class="supporting-text">Helper text</div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(
              clear_button: true,
              data: { foo: 'bar' },
              error_message: 'Error message',
              focus_indicator: true,
              leading_icon: 'leading_icon',
              show_error_icon: true,
              show_error_message: true,
              supporting_text: 'Helper text',
              trailing_icon: 'trailing_icon'
            ) do
              tag.input(type: 'text', name: 'name')
            end
          )
        end

        def test_haptic_text_field_tag_with_block_and_label
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  <input type="text" name="name">
                  <label class="field-label">Label</label>
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag('Label') do
              tag.input(type: 'text', name: 'name')
            end
          )
        end

        def test_haptic_text_field_tag_with_block_label_and_options
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field animated-label focus-indicator="focus" data-foo="bar">
                <div class="field-container">
                  <input type="text" name="name">
                  <label class="field-label">Label</label>
                  <button type="button" class="clear-button">
                    <div class="haptic-icon">close</div>
                  </button>
                  <div class="haptic-icon error-icon">error</div>
                  <div class="haptic-icon leading-icon">leading_icon</div>
                  <div class="haptic-icon trailing-icon">trailing_icon</div>
                </div>
                <div class="error-message">Error message</div>
                <div class="supporting-text">Helper text</div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(
              'Label',
              animated_label: true,
              clear_button: true,
              data: { foo: 'bar' },
              error_message: 'Error message',
              focus_indicator: true,
              leading_icon: 'leading_icon',
              show_error_icon: true,
              show_error_message: true,
              supporting_text: 'Helper text',
              trailing_icon: 'trailing_icon'
            ) do
              tag.input(type: 'text', name: 'name')
            end
          )
        end
      end
    end
  end
end
