# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class FormOptionsHelperTest < ActionView::TestCase
        include FormOptionsHelper
        include TagHelper

        def test_haptic_options
          assert_dom_equal(
            <<~HTML,
              <haptic-option value="blue">Blue</haptic-option>
              <haptic-option value="green">Green</haptic-option>
            HTML
            haptic_options([%w[Blue blue], %w[Green green]])
          )
        end

        def test_haptic_options_with_selected
          assert_dom_equal(
            <<~HTML,
              <haptic-option value="blue" checked="checked">Blue</haptic-option>
              <haptic-option value="green">Green</haptic-option>
            HTML
            haptic_options([%w[Blue blue], %w[Green green]], 'blue')
          )
        end

        def test_haptic_options_with_selected_keyword
          assert_dom_equal(
            <<~HTML,
              <haptic-option value="blue" checked="checked">Blue</haptic-option>
              <haptic-option value="green">Green</haptic-option>
            HTML
            haptic_options([%w[Blue blue], %w[Green green]], selected: 'blue')
          )
        end

        def test_haptic_options_with_disabled_option
          assert_dom_equal(
            <<~HTML,
              <haptic-option value="blue" disabled="disabled">Blue</haptic-option>
              <haptic-option value="green">Green</haptic-option>
            HTML
            haptic_options([%w[Blue blue], %w[Green green]], disabled: 'blue')
          )
        end

        def test_haptic_options_with_multiple_disabled_optoins
          assert_dom_equal(
            <<~HTML,
              <haptic-option value="blue" disabled="disabled">Blue</haptic-option>
              <haptic-option value="green" disabled="disabled">Green</haptic-option>
            HTML
            haptic_options([%w[Blue blue], %w[Green green]], disabled: %w[blue green])
          )
        end

        def test_haptic_options_with_choices_nil
          assert_nil haptic_options(nil)
        end

        def test_haptic_options_from_collection
          assert_dom_equal(
            <<~HTML,
              <haptic-option value="blue">Blue</haptic-option>
              <haptic-option value="green">Green</haptic-option>
            HTML
            haptic_options_from_collection(%w[Blue Green], :downcase, :itself)
          )
        end

        def test_haptic_options_from_collection_with_value_method_as_proc
          assert_dom_equal(
            <<~HTML,
              <haptic-option value="blue">Blue</haptic-option>
              <haptic-option value="green">Green</haptic-option>
            HTML
            haptic_options_from_collection(
              %w[Blue Green],
              ->(color) { color.downcase },
              :itself
            )
          )
        end

        def test_haptic_options_from_collection_with_name_method_as_proc
          assert_dom_equal(
            <<~HTML,
              <haptic-option value="blue">Blue</haptic-option>
              <haptic-option value="green">Green</haptic-option>
            HTML
            haptic_options_from_collection(
              %w[Blue Green],
              :downcase,
              ->(color) { color }
            )
          )
        end

        def test_haptic_options_from_collection_with_selected
          assert_dom_equal(
            <<~HTML,
              <haptic-option value="blue" checked="checked">Blue</haptic-option>
              <haptic-option value="green">Green</haptic-option>
            HTML
            haptic_options_from_collection(%w[Blue Green], :downcase, :itself, 'blue')
          )
        end

        def test_haptic_options_from_collection_with_selected_keyword
          assert_dom_equal(
            <<~HTML,
              <haptic-option value="blue" checked="checked">Blue</haptic-option>
              <haptic-option value="green" >Green</haptic-option>
            HTML
            haptic_options_from_collection(%w[Blue Green], :downcase, :itself, selected: 'blue')
          )
        end

        def test_haptic_options_from_collection_with_disabled_option
          assert_dom_equal(
            <<~HTML,
              <haptic-option value="blue" disabled="disabled">Blue</haptic-option>
              <haptic-option value="green">Green</haptic-option>
            HTML
            haptic_options_from_collection(%w[Blue Green], :downcase, :itself, disabled: 'blue')
          )
        end

        def test_haptic_options_from_collection_with_multiple_disabled_options
          assert_dom_equal(
            <<~HTML,
              <haptic-option value="blue" disabled="disabled">Blue</haptic-option>
              <haptic-option value="green" disabled="disabled">Green</haptic-option>
            HTML
            haptic_options_from_collection(
              %w[Blue Green],
              :downcase,
              :itself,
              disabled: %w[blue green]
            )
          )
        end

        def test_haptic_options_from_collection_with_disabled_as_proc
          assert_dom_equal(
            <<~HTML,
              <haptic-option value="blue" disabled="disabled">Blue</haptic-option>
              <haptic-option value="green">Green</haptic-option>
            HTML
            haptic_options_from_collection(
              %w[Blue Green],
              :downcase,
              :itself,
              disabled: ->(value) { value == 'Blue' }
            )
          )
        end

        def test_haptic_options_from_collection_with_include_blank
          assert_dom_equal(
            <<~HTML,
              <haptic-option value=""></haptic-option>
              <haptic-option value="blue">Blue</haptic-option>
              <haptic-option value="green">Green</haptic-option>
            HTML
            haptic_options_from_collection(
              %w[Blue Green],
              :downcase,
              :itself,
              include_blank: true
            )
          )
        end

        def test_haptic_options_from_collection_with_include_blank_and_prompt
          assert_dom_equal(
            <<~HTML,
              <haptic-option value="">Choose a color</haptic-option>
              <haptic-option value="blue">Blue</haptic-option>
              <haptic-option value="green">Green</haptic-option>
            HTML
            haptic_options_from_collection(
              %w[Blue Green],
              :downcase,
              :itself,
              include_blank: true,
              prompt: 'Choose a color'
            )
          )
        end

        def test_haptic_options_from_collection_with_disabled_blank_value
          assert_dom_equal(
            <<~HTML,
              <haptic-option value="" disabled="disabled"></haptic-option>
              <haptic-option value="blue">Blue</haptic-option>
              <haptic-option value="green">Green</haptic-option>
            HTML
            haptic_options_from_collection(
              %w[Blue Green],
              :downcase,
              :itself,
              include_blank: true,
              disabled: ''
            )
          )
        end

        def test_haptic_options_from_collection_with_collection_nil
          assert_nil haptic_options_from_collection(nil, :code, :name)
        end
      end
    end
  end
end
