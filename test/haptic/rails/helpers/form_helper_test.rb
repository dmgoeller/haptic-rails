# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class FormHelperTest < ActionView::TestCase
        include DropdownTagHelper
        include FormHelper
        include FormOptionsHelper

        def form_for(record, options = {})
          form_builder = options[:builder].new(
            record.class.model_name.param_key,
            record,
            self,
            {}
          )
          tag.form(**options[:html]) { yield form_builder }
        end

        # #haptic_async_form_for

        def test_haptic_async_form_for
          assert_dom_equal(
            <<~HTML,
              <form is="haptic-async-form"></form>
            HTML
            haptic_async_form_for(Dummy.new) {}
          )
        end

        def test_haptic_async_form_for_with_submit_on_change
          assert_dom_equal(
            <<~HTML,
              <form is="haptic-async-form" data-submit-on-change=""></form>
            HTML
            haptic_async_form_for(Dummy.new, submit_on_change: true) {}
          )
        end

        # #haptic_async_form_for

        def test_haptic_form_for
          assert_dom_equal(
            <<~HTML,
              <form is="haptic-form"></form>
            HTML
            haptic_form_for(Dummy.new) {}
          )
        end

        # #haptic_select_dropdown

        def test_haptic_select_dropdown
          assert_dom_equal(
            <<~HTML,
              <haptic-select-dropdown>
                <input type="text" name="color" id="color">
                <button class="toggle haptic-field" type="button"></button>
                <div class="popover">
                  <div class="scroll-container">
                    <haptic-option value="blue">Blue</haptic-option>
                    <haptic-option value="green">Green</haptic-option>
                  </div>
                </div>
                <div class="backdrop"></div>
              </haptic-select-dropdown>
            HTML
            haptic_select_dropdown(
              nil,
              :color,
              haptic_options([%w[Blue blue], %w[Green green]])
            )
          )
        end

        def test_haptic_select_dropdown_with_custom_id
          assert_dom_equal(
            <<~HTML,
              <haptic-select-dropdown>
                <input type="text" name="color" id="custom-id">
                <button class="toggle haptic-field" type="button"></button>
                <div class="popover">
                  <div class="scroll-container">
                    <haptic-option value="blue">Blue</haptic-option>
                    <haptic-option value="green">Green</haptic-option>
                  </div>
                </div>
                <div class="backdrop"></div>
              </haptic-select-dropdown>
            HTML
            haptic_select_dropdown(
              nil,
              :color,
              haptic_options([%w[Blue blue], %w[Green green]]),
              id: 'custom-id'
            )
          )
        end

        def test_haptic_select_dropdown_with_object_name
          assert_dom_equal(
            <<~HTML,
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
            HTML
            haptic_select_dropdown(
              :dummy,
              :color,
              haptic_options([%w[Blue blue], %w[Green green]])
            )
          )
        end

        def test_haptic_select_dropdown_with_object_name_and_custom_id
          assert_dom_equal(
            <<~HTML,
              <haptic-select-dropdown>
                <input type="text" name="dummy[color]" id="custom-id">
                <button class="toggle haptic-field" type="button"></button>
                <div class="popover">
                  <div class="scroll-container">
                    <haptic-option value="blue">Blue</haptic-option>
                    <haptic-option value="green">Green</haptic-option>
                  </div>
                </div>
                <div class="backdrop"></div>
              </haptic-select-dropdown>
            HTML
            haptic_select_dropdown(
              :dummy,
              :color,
              haptic_options([%w[Blue blue], %w[Green green]]),
              id: 'custom-id'
            )
          )
        end

        def test_haptic_select_dropdown_with_custom_class
          assert_dom_equal(
            <<~HTML,
              <haptic-select-dropdown>
                <input type="text" name="color" id="color">
                <button class="toggle haptic-field custom" type="button"></button>
                <div class="popover">
                  <div class="scroll-container">
                    <haptic-option value="blue">Blue</haptic-option>
                    <haptic-option value="green">Green</haptic-option>
                  </div>
                </div>
                <div class="backdrop"></div>
              </haptic-select-dropdown>
            HTML
            haptic_select_dropdown(
              nil,
              :color,
              haptic_options([%w[Blue blue], %w[Green green]]),
              class: 'custom'
            )
          )
        end

        def test_required_haptic_select_dropdown
          assert_dom_equal(
            <<~HTML,
              <haptic-select-dropdown>
                <input type="text" name="color" id="color" required="required">
                <button class="toggle haptic-field" type="button"></button>
                <div class="popover">
                  <div class="scroll-container">
                    <haptic-option value="blue">Blue</haptic-option>
                    <haptic-option value="green">Green</haptic-option>
                  </div>
                </div>
                <div class="backdrop"></div>
              </haptic-select-dropdown>
            HTML
            haptic_select_dropdown(
              nil,
              :color,
              haptic_options([%w[Blue blue], %w[Green green]]),
              required: true
            )
          )
        end

        def test_disabled_haptic_select_dropdown
          assert_dom_equal(
            <<~HTML,
              <haptic-select-dropdown>
                <input type="text" name="color" id="color" disabled="disabled">
                <button class="toggle haptic-field" type="button"></button>
                <div class="popover">
                  <div class="scroll-container">
                    <haptic-option value="blue">Blue</haptic-option>
                    <haptic-option value="green">Green</haptic-option>
                  </div>
                </div>
                <div class="backdrop"></div>
              </haptic-select-dropdown>
            HTML
            haptic_select_dropdown(
              nil,
              :color,
              haptic_options([%w[Blue blue], %w[Green green]]),
              disabled: true
            )
          )
        end
      end
    end
  end
end
