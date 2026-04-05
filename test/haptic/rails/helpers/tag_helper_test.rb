# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class TagHelperTest < ActionView::TestCase
        include TagHelper

        %w[
          haptic-button-segment
          haptic-chip
          haptic-menu
          haptic-list
          haptic-list-item
          haptic-option
          haptic-segmented-button
          haptic-tab-bar
          haptic-tabs
        ].each do |tag_name|
          method_name = :"#{tag_name.underscore}_tag"

          define_method(:"test_#{method_name}") do
            assert_dom_equal(
              <<~HTML,
                <#{tag_name}></#{tag_name}>
              HTML
              send(method_name)
            )
          end

          define_method(:"test_#{method_name}_with_options") do
            assert_dom_equal(
              <<~HTML,
                <#{tag_name} foo="bar"></#{tag_name}>
              HTML
              send(method_name, foo: 'bar')
            )
          end

          define_method(:"test_#{method_name}_with_content") do
            assert_dom_equal(
              <<~HTML,
                <#{tag_name}>Content</#{tag_name}>
              HTML
              send(method_name, 'Content')
            )
          end

          define_method(:"test_#{method_name}_with_content_and_options") do
            assert_dom_equal(
              <<~HTML,
                <#{tag_name} foo="bar">Content</#{tag_name}>
              HTML
              send(method_name, 'Content', foo: 'bar')
            )
          end

          define_method(:"test_#{method_name}_with_block") do
            assert_dom_equal(
              <<~HTML,
                <#{tag_name}>Content</#{tag_name}>
              HTML
              send(method_name) { 'Content' }
            )
          end

          define_method(:"test_#{method_name}_with_block_and_options") do
            assert_dom_equal(
              <<~HTML,
                <#{tag_name} foo="bar">Content</#{tag_name}>
              HTML
              send(method_name, foo: 'bar') { 'Content' }
            )
          end
        end

        def test_haptic_option_tag_with_checked_option
          assert_dom_equal(
            <<~HTML,
              <haptic-option checked="checked"></haptic-option>
            HTML
            haptic_option_tag(checked: true)
          )
        end

        %w[
          haptic-dropdown
          haptic-dropdown-dialog
          haptic-dropdown-menu
          haptic-select-dropdown
        ].each do |tag_name|
          method_name = :"#{tag_name.underscore}_tag"

          define_method(:"test_#{method_name}") do
            assert_dom_equal(
              <<~HTML,
                <#{tag_name}>
                  <div class="backdrop"></div>
                </#{tag_name}>
              HTML
              send(method_name)
            )
          end

          define_method(:"test_#{method_name}_with_options") do
            assert_dom_equal(
              <<~HTML,
                <#{tag_name} foo="bar">
                  <div class="backdrop"></div>
                </#{tag_name}>
              HTML
              send(method_name, foo: 'bar')
            )
          end

          define_method(:"test_#{method_name}_with_content") do
            assert_dom_equal(
              <<~HTML,
                <#{tag_name}>
                  <div class="toggle"></div>
                  <div class="popover"></div>
                  <div class="backdrop"></div>
                </#{tag_name}>
              HTML
              send(
                method_name,
                tag.div(class: 'toggle') + tag.div(class: 'popover')
              )
            )
          end

          define_method(:"test_#{method_name}_with_content_and_options") do
            assert_dom_equal(
              <<~HTML,
                <#{tag_name} foo="bar">
                  <div class="toggle"></div>
                  <div class="popover"></div>
                  <div class="backdrop"></div>
                </#{tag_name}>
              HTML
              send(
                method_name,
                tag.div(class: 'toggle') + tag.div(class: 'popover'),
                foo: 'bar'
              )
            )
          end

          define_method(:"test_#{method_name}_with_block") do
            assert_dom_equal(
              <<~HTML,
                <#{tag_name}>
                  <div class="toggle"></div>
                  <div class="popover"></div>
                  <div class="backdrop"></div>
                </#{tag_name}>
              HTML
              send(method_name) do
                tag.div(class: 'toggle') + tag.div(class: 'popover')
              end
            )
          end

          define_method(:"test_#{method_name}_with_block_and_options") do
            assert_dom_equal(
              <<~HTML,
                <#{tag_name} foo="bar">
                  <div class="toggle"></div>
                  <div class="popover"></div>
                  <div class="backdrop"></div>
                </#{tag_name}>
              HTML
              send(method_name, foo: 'bar') do
                tag.div(class: 'toggle') + tag.div(class: 'popover')
              end
            )
          end
        end

        %w[haptic-dropdown-dialog haptic-dropdown-menu].each do |tag_name|
          method_name = :"#{tag_name.underscore}_tag"

          define_method(:"test_#{method_name}_with_open_to_top_option") do
            assert_dom_equal(
              <<~HTML,
                <#{tag_name} open-to-top>
                  <div class="backdrop"></div>
                </#{tag_name}>
              HTML
              send(method_name, open_to_top: true)
            )
          end
        end

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

        def test_haptic_dropdown_field_tag_with_options
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-field focus-indicator="focus">
                <div class="field-container">
                  <div class="haptic-icon error-icon">error</div>
                  <div class="haptic-icon leading-icon">leading_icon</div>
                </div>
                <div class="error-message">Error message</div>
                <div class="supporting-text">Helper text</div>
              </haptic-dropdown-field>
            HTML
            haptic_dropdown_field_tag(
              focus_indicator: true,
              error_message: 'Error message',
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
              <haptic-dropdown-field focus-indicator="focus">
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
              focus_indicator: true,
              error_message: 'Error message',
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

        def test_haptic_dropdown_field_tag_with_field_label_and_options
          assert_dom_equal(
            <<~HTML,
              <haptic-dropdown-field animated-label focus-indicator="focus">
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
              focus_indicator: true,
              error_message: 'Error message',
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
              <haptic-dropdown-field focus-indicator="focus">
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
              focus_indicator: true,
              error_message: 'Error message',
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
              <haptic-dropdown-field animated-label focus-indicator="focus">
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
              focus_indicator: true,
              error_message: 'Error message',
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

        def test_haptic_text_field_tag_with_options
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field focus-indicator="focus">
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
              focus_indicator: true,
              error_message: 'Error message',
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
              <haptic-text-field focus-indicator="focus">
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
              focus_indicator: true,
              error_message: 'Error message',
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

        def test_haptic_text_field_tag_with_field_label_and_options
          assert_dom_equal(
            <<~HTML,
              <haptic-text-field animated-label focus-indicator="focus">
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
              focus_indicator: true,
              error_message: 'Error message',
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
              <haptic-text-field focus-indicator="focus">
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
              focus_indicator: true,
              error_message: 'Error message',
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
              <haptic-text-field animated-label focus-indicator="focus">
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
              focus_indicator: true,
              error_message: 'Error message',
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
