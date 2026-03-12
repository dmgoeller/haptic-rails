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

        def test_haptic_dialog_with_custom_class
          assert_dom_equal(
            <<~HTML,
              <dialog class="haptic-dialog foo"></dialog>
            HTML
            haptic_dialog(class: 'foo')
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

        def test_haptic_dialog_with_custom_class_and_block
          assert_dom_equal(
            <<~HTML,
              <dialog class="haptic-dialog foo">
                <div class="dialog-header">Headline</div>
              </dialog>
            HTML
            haptic_dialog(class: 'foo') do |dialog|
              dialog.header 'Headline'
            end
          )
        end
      end
    end
  end
end
