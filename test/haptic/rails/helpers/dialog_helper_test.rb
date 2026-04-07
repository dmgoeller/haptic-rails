# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class DialogHelperTest < ActionView::TestCase
        include DialogHelper

        def test_haptic_dialog
          assert_dom_equal(
            <<~HTML,
              <dialog class="haptic-dialog"></dialog>
            HTML
            haptic_dialog
          )
        end

        def test_haptic_dialog_with_options
          assert_dom_equal(
            <<~HTML,
              <dialog class="haptic-dialog foo-class" data-foo="bar"></dialog>
            HTML
            haptic_dialog(class: 'foo-class', data: { foo: 'bar' })
          )
        end

        def test_haptic_dialog_with_block
          assert_dom_equal(
            <<~HTML,
              <dialog class="haptic-dialog">
                <div class="dialog-header">Headline</div>
              </dialog>
            HTML
            haptic_dialog do |dialog|
              dialog.header 'Headline'
            end
          )
        end

        def test_haptic_dialog_with_block_and_options
          assert_dom_equal(
            <<~HTML,
              <dialog class="haptic-dialog foo-class" data-foo="bar">
                <div class="dialog-header">Headline</div>
              </dialog>
            HTML
            haptic_dialog(class: 'foo-class', data: { foo: 'bar' }) do |dialog|
              dialog.header 'Headline'
            end
          )
        end
      end
    end
  end
end
