# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    module Helpers
      class IconHelperTest < ActionView::TestCase
        def test_haptic_icon_tag
          assert_dom_equal(
            <<~HTML,
              <div class="haptic-icon">close</div>
            HTML
            haptic_icon_tag('close')
          )
        end

        def test_haptic_icon_tag_with_additional_class
          assert_dom_equal(
            <<~HTML,
              <div class="haptic-icon foo">close</div>
            HTML
            haptic_icon_tag('close', class: 'foo')
          )
        end

        def test_haptic_icon_tag_on_nil_icon_builder
          Configuration.stub_any_instance(:icon_builder, nil) do
            assert_nil(haptic_icon_tag('close'))
          end
        end
      end
    end
  end
end
