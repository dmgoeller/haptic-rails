# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class DropdownTagHelperTest < ActionView::TestCase
        include DropdownTagHelper
        include IconTagHelper

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
      end
    end
  end
end
