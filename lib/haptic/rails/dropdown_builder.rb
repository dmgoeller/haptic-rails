# frozen_string_literal: true

module Haptic
  module Rails
    class DropdownBuilder
      def initialize(builder, toggle_options = {}) # :nodoc:
        @builder = builder
        @toggle_options = toggle_options.symbolize_keys
        @toggle_class = @toggle_options.delete(:class)
      end

      # Creates the toggle button.
      #
      # ==== Example
      #
      #   toggle('Text')
      #   # =>
      #   # <button type="button" class="toggle">Text</button>
      def toggle(content = nil, **options, &block)
        @builder.tag.button(
          content,
          **@toggle_options.merge(
            type: 'button',
            class: ['toggle', @toggle_class, options[:class]],
            **options.except(:class)
          ),
          &block
        )
      end
    end
  end
end
