# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class FormHelperTest < ActionView::TestCase
        include FormHelper

        def form_for(record, options = {})
          form_builder = options[:builder].new(
            record.class.model_name.param_key,
            record,
            self,
            {}
          )
          content_tag('form', options[:html]) do
            yield form_builder
          end
        end

        def test_haptic_async_checkbox_for
          assert_dom_equal(
            <<~HTML,
              <form is="haptic-async-form">
                <input name="dummy[color]" type="hidden" value="0" autocomplete="off" />
                <input type="checkbox" is="haptic-input" class="async"
                  id="dummy_color" name="dummy[color]" value="red"
                  onchange="this.form.requestSubmit()" />
              </form>
            HTML
            haptic_async_checkbox_for(Dummy.new, :color, {}, 'red', 'green')
          )
        end

        def test_haptic_async_form_for
          assert_dom_equal(
            <<~HTML,
              <form is="haptic-async-form"></form>
            HTML
            haptic_async_form_for(Dummy.new) {}
          )
        end

        def test_haptic_form_for
          assert_dom_equal(
            <<~HTML,
              <form is="haptic-form"></form>
            HTML
            haptic_form_for(Dummy.new) {}
          )
        end
      end
    end
  end
end
