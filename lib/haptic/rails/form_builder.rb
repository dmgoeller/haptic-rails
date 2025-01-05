# frozen_string_literal: true

module Haptic
  module Rails
    # Builds forms with haptic components.
    class FormBuilder < ActionView::Helpers::FormBuilder
      HAPTIC_TEXT_FIELD_OPTIONS = %i[
        animated
        clear_button
        focus_indicator
        haptic_field_id
        label
        leading_icon
        set_valid_on_change
        show_error_icon
        show_error_message
        supporting_text
        trailing_icon
      ].freeze

      def initialize(object_name, object, template, options)
        @field_options = FieldOptions.new
        super(object_name, object, Builder.new(template, @field_options), options)
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

      %i[file_field number_field text_area text_field].each do |name|
        define_method name do |method, options = {}|
          options = @field_options.merge(options)
          field = super(method, options.except(*HAPTIC_TEXT_FIELD_OPTIONS))
          return field unless HAPTIC_TEXT_FIELD_OPTIONS.any? { |key| options.key? key }

          haptic_field('text', method, field, options)
        end
      end

      def button_segments(method, collection, value_method, text_method, options = {}, &block)
        collection_radio_buttons(method, collection, value_method, text_method, options) do |b|
          @template.content_tag('div', class: 'haptic-button-segment') do
            block ? block.call(b) : b.radio_button(is: nil) + b.label(is: nil)
          end
        end
      end

      def chips(method, collection, value_method, text_method, options = {}, &block)
        collection_check_boxes(method, collection, value_method, text_method, options) do |b|
          @template.content_tag('div', class: 'haptic-chip') do
            block ? block.call(b) : b.check_box(is: nil) + b.label(is: nil)
          end
        end
      end

      def date_field(method, options = {})
        options = @field_options.merge(options)

        haptic_field(
          'text',
          method,
          super(method, options.except(*HAPTIC_TEXT_FIELD_OPTIONS)),
          options.reverse_merge(trailing_icon: 'calendar').except(:animated)
        )
      end

      def error_messages(method, options = {})
        error_message = error_message_for(method)
        return if error_message.blank?

        @template.content_tag(
          'div',
          error_message,
          options.merge(class: [options[:class], 'error'])
        )
      end

      def list(method, collection, value_method, text_method, options = {}, &block)
        @template.content_tag('ul', class: 'haptic-list') do
          list_items(method, collection, value_method, text_method, options, &block)
        end
      end

      def list_items(method, collection, value_method, text_method, options = {}, &block)
        collection_check_boxes(method, collection, value_method, text_method, options) do |b|
          @template.content_tag('li', is: 'haptic-list-item') do
            block ? block.call(b) : b.check_box + b.label
          end
        end
      end

      def segmented_button(method, collection, value_method, text_method, options = {})
        @template.haptic_segmented_button_tag do
          button_segments(method, collection, value_method, text_method, options)
        end
      end

      def select(method, choices = nil, options = {}, html_options = {}, &block)
        haptic_field('dropdown', method, super, @field_options.merge(options))
      end

      def with_field_options(options = {})
        @field_options.push(options)
        begin
          yield if block_given?
        ensure
          @field_options.pop
        end
      end

      private

      def error_message_for(method)
        # Don't call :valid? or :invalid? here to prevent errors on new records
        full_messages = object&.errors&.full_messages_for(method)
        return if full_messages.blank?

        "#{full_messages.map { |m| m.delete_suffix('.') }.join('. ')}."
      end

      def haptic_field(type, method, field, options = {})
        options = options.slice(*HAPTIC_TEXT_FIELD_OPTIONS)
        options[:for] = _field_id(method)
        options[:invalid] = object&.errors&.key?(method) || false
        options[:error_message] = error_message_for(method)

        set_valid_on_change = options[:set_valid_on_change]
        if [nil, '', true, false].exclude?(set_valid_on_change)
          options[:set_valid_on_change] =
            Array(set_valid_on_change)
              .map { |name| _field_id(name) }
              .join(' ')
              .presence
        end

        label =
          if (label_option = options.delete(:label))
            args = [:label, method]
            args << label_option unless label_option == true
            send(*args, is: nil)
          end

        @template.haptic_field_tag(type, field, label, options)
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
