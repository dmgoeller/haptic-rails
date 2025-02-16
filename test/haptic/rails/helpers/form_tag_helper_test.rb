# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class FormTagHelperTest < ActionView::TestCase
        include FormTagHelper

        def test_haptic_dialog_dropdown_tag
          assert_dom_equal(
            <<~HTML,
              <haptic-dialog-dropdown>
                <div class="backdrop"></div>
              </haptic-dialog-dropdown>
            HTML
            haptic_dialog_dropdown_tag
          )
        end

        def test_haptic_dialog_dropdown_tag_with_block
          assert_dom_equal(
            <<~HTML,
              <haptic-dialog-dropdown>
                <div class="toggle"></div>
                <div class="popover"></div>
                <div class="backdrop"></div>
              </haptic-dialog-dropdown>
            HTML
            haptic_dialog_dropdown_tag do
              content_tag('div', '', class: 'toggle') +
                content_tag('div', '', class: 'popover')
            end
          )
        end

        def test_haptic_dropdown_field_tag
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-field>
                <div class="field-container">
                  <label class="field-label">Label</label>
                </div>
              </haptic-dropdown-field>
            HTML
            haptic_dropdown_field_tag('', 'Label')
          )
        end

        def test_haptic_list_tag
          assert_dom_equal(
            <<~HTML,
              <haptic-list></haptic-list>
            HTML
            haptic_list_tag
          )
        end

        def test_haptic_list_item_tag
          assert_dom_equal(
            <<~HTML,
              <haptic-list-item></haptic-list-item>
            HTML
            haptic_list_item_tag
          )
        end

        def test_haptic_option_list_tag
          assert_dom_equal(
            <<~HTML,
              <haptic-option-list></haptic-option-list>
            HTML
            haptic_option_list_tag
          )
        end

        def test_haptic_option_tag
          assert_dom_equal(
            <<~HTML,
              <haptic-option></haptic-option>
            HTML
            haptic_option_tag
          )
        end

        def test_haptic_option_tag_on_checked
          assert_dom_equal(
            <<~HTML,
              <haptic-option checked="checked"></haptic-option>
            HTML
            haptic_option_tag('', checked: true)
          )
        end

        def test_haptic_segmented_button_tag
          assert_dom_equal(
            <<~HTML,
              <haptic-segmented-button></haptic-segmented-button>
            HTML
            haptic_segmented_button_tag
          )
        end

        def test_haptic_select_dropdown_tag
          assert_dom_equal(
            <<~HTML,
              <haptic-select-dropdown>
                <div class="backdrop"></div>
              </haptic-select-dropdown>
            HTML
            haptic_select_dropdown_tag
          )
        end

        def test_haptic_select_dropdown_tag_with_block
          assert_dom_equal(
            <<~HTML,
              <haptic-select-dropdown>
                <div class="toggle"></div>
                <div class="popover"></div>
                <div class="backdrop"></div>
              </haptic-select-dropdown>
            HTML
            haptic_select_dropdown_tag do
              content_tag('div', '', class: 'toggle') +
                content_tag('div', '', class: 'popover')
            end
          )
        end

        def test_haptic_select_dropdown_tag_on_to_top_true
          assert_dom_equal(
            <<~HTML,
              <haptic-select-dropdown to-top="">
                <div class="backdrop"></div>
              </haptic-select-dropdown>
            HTML
            haptic_select_dropdown_tag(to_top: true)
          )
        end

        def test_haptic_select_dropdown_tag_on_to_top_false
          assert_dom_equal(
            <<~HTML,
              <haptic-select-dropdown>
                <div class="backdrop"></div>
              </haptic-select-dropdown>
            HTML
            haptic_select_dropdown_tag(to_top: false)
          )
        end

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

        def test_haptic_text_field_tag_with_field
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  #{field = '<input name="name" type="text">'}
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(field)
          )
        end

        def test_haptic_text_field_tag_with_field_and_label
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  #{field = '<input name="name" type="text">'}
                  <label class="field-label">Label</label>
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(field, 'Label')
          )
        end

        def test_haptic_text_field_tag_with_field_and_clear_button
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  #{field = '<input name="name" type="text">'}
                  <button type="button" tabindex="-1" class="clear-button">
                    <div class="haptic-icon">close</div>
                  </button>
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(field, clear_button: true)
          )
        end

        def test_haptic_text_field_tag_with_field_and_leading_icon
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  #{field = '<input name="name" type="text">'}
                  <div class="haptic-icon leading-icon">leading_icon</div>
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(field, leading_icon: 'leading_icon')
          )
        end

        def test_haptic_text_field_tag_with_field_and_trailing_icon
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  #{field = '<input name="name" type="text">'}
                  <div class="haptic-icon trailing-icon">trailing_icon</div>
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(field, trailing_icon: 'trailing_icon')
          )
        end

        def test_haptic_text_field_tag_with_field_and_error_message
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  #{field = '<input name="name" type="text">'}
                </div>
                <div class="error-message">Message</div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(field, error_message: 'Message', show_error_message: true)
          )
        end

        def test_haptic_text_field_tag_with_field_and_supporting
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                #{field = '<input name="name" type="text">'}
                </div>
                <div class="supporting-text">Text</div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(field, supporting_text: 'Text')
          )
        end

        def test_haptic_text_field_tag_with_block
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  <input id="name" name="name" type="text">
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag { text_field_tag('name') }
          )
        end

        def test_haptic_text_field_tag_with_block_and_label
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  <input id="name" name="name" type="text">
                  <label class="field-label">Label</label>
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag('Label') { text_field_tag('name') }
          )
        end

        def test_haptic_text_field_tag_with_block_and_clear_button
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  <input id="name" name="name" type="text">
                  <button type="button" tabindex="-1" class="clear-button">
                    <div class="haptic-icon">close</div>
                  </button>
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(clear_button: true) { text_field_tag('name') }
          )
        end

        def test_haptic_text_field_tag_with_block_and_error_icon
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  <input id="name" name="name" type="text">
                  <div class="haptic-icon error-icon">error</div>
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(show_error_icon: true) { text_field_tag('name') }
          )
        end

        def test_haptic_text_field_tag_with_block_and_leading_icon
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  <input id="name" name="name" type="text">
                  <div class="haptic-icon leading-icon">leading_icon</div>
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(leading_icon: 'leading_icon') { text_field_tag('name') }
          )
        end

        def test_haptic_text_field_tag_with_block_and_trailing_icon
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  <input id="name" name="name" type="text">
                  <div class="haptic-icon trailing-icon">trailing_icon</div>
                </div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(trailing_icon: 'trailing_icon') { text_field_tag('name') }
          )
        end

        def test_haptic_text_field_tag_with_block_and_error_message
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  <input id="name" name="name" type="text">
                </div>
                <div class="error-message">Message</div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(error_message: 'Message', show_error_message: true) do
              text_field_tag('name')
            end
          )
        end

        def test_haptic_text_field_tag_with_block_and_supporting_text
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field>
                <div class="field-container">
                  <input id="name" name="name" type="text">
                </div>
                <div class="supporting-text">Text</div>
              </haptic-text-field>
            HTML
            haptic_text_field_tag(supporting_text: 'Text') { text_field_tag('name') }
          )
        end
      end
    end
  end
end
