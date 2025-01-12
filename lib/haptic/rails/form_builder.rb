# frozen_string_literal: true

module Haptic
  module Rails
    # Builds forms with haptic components.
    class FormBuilder < ActionView::Helpers::FormBuilder
      HAPTIC_FIELD_OPTIONS = %i[
        animated_label
        clear_button
        field_id
        focus_indicator
        haptic_field_id
        label
        leading_icon
        reset_and_close_dropdown_on_focus
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
        define_method(name) do |method, options = {}|
          options = @field_options.merge(options)
          field = super(method, options.except(*HAPTIC_FIELD_OPTIONS))
          return field unless HAPTIC_FIELD_OPTIONS.any? { |key| options.key? key }

          haptic_field('text', method, field, options)
        end
      end

      ##
      # :method: chips
      # :call-seq: chips(method, choices, options = {}, &block)

      ##
      # :method: list
      # :call-seq: list(method, choices, options = {}, &block)

      ##
      # :method: list
      # :call-seq: segmented_button(method, choices, options = {})

      %i[chips list segmented_button].each do |name|
        define_method(name) do |method, choices, options = {}, &block|
          choices = choices.to_a if choices.is_a?(Hash)
          public_send(:"collection_#{name}", method, choices, :last, :first, options, &block)
        end
      end

      def collection_chips(method, collection, value_method, text_method, options = {}, &block)
        collection_check_boxes(method, collection, value_method, text_method, options) do |b|
          @template.content_tag('div', class: 'haptic-chip') do
            block ? block.call(b) : b.check_box(is: nil) + b.label(is: nil)
          end
        end
      end

      def collection_list(method, collection, value_method, text_method, options = {}, &block)
        options = options.stringify_keys

        @template.haptic_list_tag(required: options.delete('required') == true) do
          if options.delete('multiple') == true
            collection_check_boxes(method, collection, value_method, text_method, options) do |b|
              @template.haptic_list_item_tag { block ? block.call(b) : b.check_box + b.label }
            end
          else
            collection_radio_buttons(method, collection, value_method, text_method, options) do |b|
              @template.haptic_list_item_tag { block ? block.call(b) : b.radio_button + b.label }
            end
          end
        end
      end

      def collection_segmented_button(method, collection, value_method, text_method, options = {}, &block)
        @template.haptic_segmented_button_tag do
          collection_radio_buttons(method, collection, value_method, text_method, options) do |b|
            @template.content_tag('div', class: 'haptic-button-segment') do
              block ? block.call(b) : b.radio_button(is: nil) + b.label(is: nil)
            end
          end
        end
      end

      def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
        haptic_field('dropdown', method, super, @field_options.merge(options))
      end

      def date_field(method, options = {})
        options = @field_options.merge(options)

        haptic_field(
          'text',
          method,
          super(method, options.except(*HAPTIC_FIELD_OPTIONS)),
          options.reverse_merge(trailing_icon: 'calendar').except(:animated_label)
        )
      end

      def dropdown_field(options = {}, &block)
        field_options = @field_options.slice(*HAPTIC_FIELD_OPTIONS)
        field_options.merge!(options)

        label = field_options.delete(:label)
        label = nil if label == true

        @template.haptic_field_tag('dropdown', label, field_options) do
          @template.haptic_dialog_dropdown_tag do
            options = @field_options.merge(class: [@field_options[:class], 'haptic-field'])
            block&.call(DropdownBuilder.new(@template, options))
          end
        end
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

      def select(method, choices = nil, options = {}, html_options = {}, &block)
        haptic_field('dropdown', method, super, @field_options.merge(options))
      end

      def select_dropdown(method, choices = nil, options = {}, &block)
        choices, options = nil, choices || {} if block
        choices = choices.to_a if choices.is_a?(Hash)
        options = @field_options.merge(options).except!(:size, :to_top)

        field = @template.haptic_select_dropdown_tag(options.slice(:size, :to_top)) do
          hidden_field(method) +
            @template.button_tag(
              '',
              options.except(*HAPTIC_FIELD_OPTIONS).merge(
                class: [options[:class], 'haptic-field', 'toggle'],
                is: nil,
                type: 'button'
              )
            ) +
            @template.content_tag('div', '', class: 'popover') do
              if choices
                selected = object.send(method)

                choices.each do |choice|
                  value = choice.last

                  @template.concat(
                    @template.content_tag(
                      'haptic-option',
                      choice.first,
                      value: value,
                      checked: value == selected
                    )
                  )
                end
              elsif block
                @template.capture(&block)
              end
            end
        end

        haptic_field('dropdown', method, field, options)
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
        options = options.slice(*HAPTIC_FIELD_OPTIONS)
        options[:id] = options.delete(:field_id)
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
            send(*args, class: 'haptic-field-label')
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
