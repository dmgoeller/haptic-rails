# frozen_string_literal: true

module Haptic
  module Rails
    # Builds forms with haptic components.
    class FormBuilder < ActionView::Helpers::FormBuilder
      HAPTIC_TEXT_FIELD_OPTIONS = %i[
        animated
        clear_button
        focus_indicator
        error_icon
        error_messages
        label
        leading_icon
        supporting_text
        trailing_icon
      ].freeze

      def initialize(object_name, object, template, options)
        @defaults = {}
        super(object_name, object, Builder.new(template, @defaults), options)
      end

      ##
      # :method: number_field
      # :call-seq: number_field(method, options = {})

      ##
      # :method: text_area
      # :call-seq: text_area(method, options = {})

      ##
      # :method: text_field
      # :call-seq: text_field(method, options = {})

      %i[number_field text_area text_field].each do |name|
        define_method name do |method, options = {}|
          options = defaults.merge(options)
          field = super(method, field_options(options))
          return field unless HAPTIC_TEXT_FIELD_OPTIONS.any? { |key| options.key? key }

          haptic_text_field(method, field, options)
        end
      end

      def defaults(defaults = {})
        @defaults.merge!(defaults) if defaults.any?
        @defaults
      end

      def errors(method, options = {})
        full_messages = object&.errors&.full_messages_for(method)
        return if full_messages.blank?

        @template.content_tag(
          :div,
          full_messages.join('. ').delete_suffix('.'),
          class: [options[:class], 'error'].flatten
        )
      end

      def segmented_button(method, collection, value_method, text_method, options = {})
        @template.content_tag('div', class: 'haptic-segmented-button') do
          collection_radio_buttons(method, collection, value_method, text_method, options) do |builder|
            @template.content_tag('div', class: 'container') do
              builder.radio_button(is: nil) + builder.label(is: nil)
            end
          end
        end
      end

      def select(method, choices = nil, options = {}, html_options = {}, &block)
        text_field_options = defaults.merge(trailing_icon: 'arrow_drop_down')
        text_field_options.merge!(options)
        text_field_options.delete(:clear_button)

        haptic_text_field(method, super, text_field_options)
      end

      private

      def field_options(options)
        options.except(*HAPTIC_TEXT_FIELD_OPTIONS)
      end

      def haptic_text_field(method, field, options = {})
        # Don't call :valid? or :invalid? here to prevent errors on new records
        errors = object&.errors&.include?(method)

        @template.content_tag('haptic-text-field',
                              'animated': ('' if options[:animated]),
                              'focus-indicator': ('' if options[:focus_indicator]),
                              'with-errors': ('' if errors)) do
          @template.content_tag('div', class: 'container') do
            field +
              if (label = options[:label])
                label == true ? label(method, is: nil) : label(method, label, is: nil)
              end +
              if options[:clear_button]
                @template.haptic_icon_tag('close', class: 'clear-button')
              end +
              if options[:error_icon] && errors
                @template.haptic_icon_tag('error', class: 'error-icon')
              end +
              if (leading_icon = options[:leading_icon])
                @template.haptic_icon_tag(leading_icon, class: 'leading-icon')
              end +
              if (trailing_icon = options[:trailing_icon])
                @template.haptic_icon_tag(trailing_icon, class: 'trailing-icon')
              end
          end +
            if options[:error_messages] && errors
              errors(method, class: 'supporting-text')
            end +
            if (supporting_text = options[:supporting_text])
              @template.content_tag('div', supporting_text, class: 'supporting-text')
            end
        end
      end
    end
  end
end
