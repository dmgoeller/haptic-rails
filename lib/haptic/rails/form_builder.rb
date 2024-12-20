# frozen_string_literal: true

module Haptic
  module Rails
    # Builds forms with haptic components.
    class FormBuilder < ActionView::Helpers::FormBuilder
      HAPTIC_TEXT_FIELD_OPTIONS = %i[
        animated
        clear_button
        focus_indicator
        label
        leading_icon
        reset_errors_on_change
        show_error_icon
        show_error_message
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

      def button_segments(method, collection, value_method, text_method, options = {})
        collection_radio_buttons(method, collection, value_method, text_method, options) do |b|
          @template.content_tag('div', class: 'haptic-button-segment') do
            b.radio_button(is: nil) + b.label(is: nil)
          end
        end
      end

      def chips(method, collection, value_method, text_method, options = {})
        collection_check_boxes(method, collection, value_method, text_method, options) do |b|
          @template.content_tag('div', class: 'haptic-chip') do
            b.check_box(is: nil) + b.label(is: nil)
          end
        end
      end

      def defaults(defaults = {})
        @defaults.merge!(defaults) if defaults.any?
        @defaults
      end

      def errors(method, options = {})
        error_message = error_message_for(method)
        @template.haptic_error_tag(error_message, options) if error_message
      end

      def segmented_button(method, collection, value_method, text_method, options = {})
        @template.content_tag('div', class: 'haptic-segmented-button') do
          button_segments(method, collection, value_method, text_method, options)
        end
      end

      def select(method, choices = nil, options = {}, html_options = {}, &block)
        text_field_options = defaults.merge(trailing_icon: 'arrow_drop_down')
        text_field_options.merge!(options)
        text_field_options.delete(:clear_button)

        haptic_text_field(method, super, text_field_options)
      end

      private

      def error_message_for(method)
        # Don't call :valid? or :invalid? here to prevent errors on new records
        full_messages = object&.errors&.full_messages_for(method)
        return if full_messages.blank?

        "#{full_messages.map { |m| m.delete_suffix('.') }.join('. ')}."
      end

      def field_options(options)
        options.except(*HAPTIC_TEXT_FIELD_OPTIONS)
      end

      def haptic_text_field(method, field, options = {})
        options = options.slice(*HAPTIC_TEXT_FIELD_OPTIONS)
        options[:for] = _field_id(method)
        options[:error_message] = error_message_for(method)

        if (reset_errors_on_change = options[:reset_errors_on_change])
          options[:reset_errors_on_change] = Array(reset_errors_on_change).map do |name|
            name == true ? 'itself' : _field_id(name)
          end.join(' ').presence
        end

        label =
          if (label_option = options.delete(:label))
            args = [:label, method]
            args << label_option unless label_option == true
            send(*args, is: nil)
          end

        @template.haptic_text_field_tag(field, label, options)
      end

      def _field_id(method)
        return field_id(method) if respond_to?(:field_id)

        object_name = @object_name
        object_name = object_name.model_name.singular if object_name.respond_to?(:model_name)
        object_name = object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, '_').delete_suffix('_')

        [object_name, method.to_s.delete_suffix('?')].tap(&:compact!).join('_')
      end
    end
  end
end
