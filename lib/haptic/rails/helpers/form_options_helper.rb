# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module FormOptionsHelper

        # Builds a string of <code><haptic-option></code> tags from the given choices.
        # <code>choices</code> can be an array, a hash or any collection whose elements
        # respond to <code>:first</code> and <code>:last</code>.
        #
        #   haptic_options [['Blue', 'blue'], ['Green', 'green']]
        #
        #   haptic_options { 'Blue' => 'blue', 'Green' => 'green' }
        #
        # The option to be checked initially can either be passed as the second positional
        # argument or the <code>:selected</code> keyword argument.
        #
        #   haptic_options [['Blue', 'blue'], ['Green', 'green']], 'green'
        #
        #   haptic_options [['Blue', 'blue'], ['Green', 'green']], selected: 'green'
        #
        # ==== Further options
        #
        # - <code>:disabled</code> - The options to be disabled. Can be a single value or
        #   an array of values.
        def haptic_options(choices, selected = nil, options = {})
          return if choices.nil?

          selected, options = selected[:selected], selected if selected.is_a?(Hash)
          disabled = Array.wrap(options[:disabled])

          choices.map do |element|
            haptic_option_tag(
              element.first,
              value: value = element.last,
              checked: value == selected,
              disabled: disabled.include?(value)
            )
          end.reduce(:+)
        end

        # Builds a string of <code><haptic-option></code> tags from the given collection by
        # calling <code>value_method</code> and <code>text_method</code> on each element.
        #
        #   haptic_options_from_collection %w[Blue Green], :downcase, :itself
        #
        #   haptic_options_from_collection %w[Blue Green],
        #                                  ->(color) { color.downcase },
        #                                  ->(color) { color }
        #
        # The option to be checked initially can either be passed as the last positional
        # argument or the <code>:selected</code> keyword argument.
        #
        #   haptic_options_from_collection %w[Blue Green], :downcase, :itself, 'green'
        #
        #   haptic_options_from_collection %w[Blue Green], :downcase, :itself, selected: 'green'
        #
        # ==== Further options
        #
        # - <code>:disabled</code> - The options to be disabled. Can be a single value, an
        #   array of values or a <code>Proc</code>.
        # - <code>:include_blank</code> - If is <code>true</code>, an option with an empty
        #   value is prepended.
        # - <code>:prompt</code> - The text of the blank option prepended.
        def haptic_options_from_collection(collection, value_method, text_method, selected = nil, options = {})
          return if collection.nil?

          value_proc, text_proc = [value_method, text_method].map do |method|
            next method if method.respond_to?(:call)

            method_name = method.to_s
            ->(element) { element.public_send(method_name) }
          end

          selected, options = selected[:selected], selected if selected.is_a?(Hash)

          disabled_proc = options[:disabled]&.then do |disabled|
            if disabled.respond_to?(:call)
              ->(element, _value) { disabled.call(element) }
            else
              disabled = Array.wrap(disabled)
              ->(_element, value) { disabled.include?(value) }
            end
          end

          [].tap do |haptic_option_tags|
            if options[:include_blank] == true
              haptic_option_tags << haptic_option_tag(
                options[:prompt] || '',
                value: '',
                checked: selected == '',
                disabled: disabled_proc&.call('', '')
              )
            end
            collection.each do |element|
              haptic_option_tags << haptic_option_tag(
                text_proc.call(element),
                value: value = value_proc.call(element),
                checked: value == selected,
                disabled: disabled_proc&.call(element, value)
              )
            end
          end.reduce(:+)
        end
      end
    end
  end
end
