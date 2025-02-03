# frozen_string_literal: true

module Haptic
  module Rails
    # Builds a form containing haptic components.
    #
    # ==== \Haptic field options
    #
    # - <code>animated_label</code>
    # - <code>clear_button</code>
    # - <code>field_id</code>
    # - <code>focus_indicator</code>
    # - <code>label</code>
    # - <code>leading_icon</code>
    # - <code>set_valid_on_change</code>
    # - <code>show_error_icon</code>
    # - <code>show_error_message</code>
    # - <code>supporting_text</code>
    # - <code>trailing_icon</code>
    class FormBuilder < ActionView::Helpers::FormBuilder
      HAPTIC_FIELD_OPTIONS = %i[
        animated_label
        clear_button
        field_id
        focus_indicator
        label
        leading_icon
        set_valid_on_change
        show_error_icon
        show_error_message
        supporting_text
        trailing_icon
      ].freeze # :nodoc:

      def initialize(object_name, object, template, options) # :nodoc:
        @field_options = FieldOptions.new
        super(object_name, object, Builder.new(template, @field_options), options)
      end

      ##
      # :method: number_field
      # :call-seq: number_field(method, options = {})
      #
      # Creates a number field. The number field is wrapped by a <code>haptic-text-field</code>
      # tag if any of the haptic field options are specified.

      ##
      # :method: text_area
      # :call-seq: text_area(method, options = {})
      #
      # Creates a text area. The text area is wrapped by a <code>haptic-text-field</code>
      # tag if any of the haptic field options are specified.

      ##
      # :method: text_field
      # :call-seq: text_field(method, options = {})
      #
      # Creates a text field. The text field is wrapped by a <code>haptic-text-field</code>
      # tag if any of the haptic field options are specified.
      #
      # ==== Examples
      #
      #   form.text_field :name
      #   # => <input is="haptic-input" type="text" name="dummy[name]" id="dummy_name">
      #
      #   form.text_field :name, label: true
      #   # =>
      #   # <haptic-text-field for="dummy_name">
      #   #   <div class="haptic-field-container">
      #   #     <input is="haptic-input" type="text" name="dummy[name]" id="dummy_name">
      #   #     <label is="haptic-label" class="haptic-field-label" for="dummy_name">Name</label>
      #   #   </div>
      #   # </haptic-text-field>

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
      #
      # ==== Examples
      #
      #   form.chips :color, [%w[Blue blue], %w[Green green]]
      #   # =>
      #   # <input type="hidden" name="dummy[color][]" value="" autocomplete="off">
      #   # <div class="haptic-chip">
      #   #   <input type="checkbox" value="blue" name="dummy[color][]" id="dummy_color_blue">
      #   #   <label for="dummy_color_blue">Blue</label>
      #   # </div>
      #   # <div class="haptic-chip">
      #   #   <input type="checkbox" value="green" name="dummy[color][]" id="dummy_color_green">
      #   #   <label for="dummy_color_green">Green</label>
      #   # </div>
      #
      #   form.chips :color, [%w[Blue blue], %w[Green green]] do |b|
      #     b.check_box(is: nil, checked: b.value == 'blue') + b.label(is: nil)
      #   end
      #   # =>
      #   # <input type="hidden" name="dummy[color][]" value="" autocomplete="off">
      #   # <div class="haptic-chip">
      #   #   <input type="checkbox" value="blue" name="dummy[color][]" id="dummy_color_blue"
      #   #     checked="checked">
      #   #   <label for="dummy_color_blue">Blue</label>
      #   # </div>
      #   # <div class="haptic-chip">
      #   #   <input type="checkbox" value="green" name="dummy[color][]" id="dummy_color_green">
      #   #   <label for="dummy_color_green">Green</label>
      #   # </div>

      ##
      # :method: list
      # :call-seq: list(method, choices, options = {}, &block)
      #
      # ==== Options
      #
      # - <code>:multiple</code> -
      # - <code>:required</code> -
      #
      # ==== Examples
      #
      #   form.list :color, [%w[Blue blue], %w[Green green]]
      #   # =>
      #   # <haptic-list>
      #   #   <input type="hidden" name="dummy[color]" value="" autocomplete="off">
      #   #   <haptic-list-item>
      #   #     <input is="haptic-input" type="radio" value="blue" name="dummy[color]"
      #   #       id="dummy_color_blue">
      #   #     <label is="haptic-label" for="dummy_color_blue">Blue</label>
      #   #   </haptic-list-item>
      #   #   <haptic-list-item>
      #   #     <input is="haptic-input" type="radio" value="green" name="dummy[color]"
      #   #       id="dummy_color_green">
      #   #     <label is="haptic-label" for="dummy_color_green">Green</label>
      #   #   </haptic-list-item>
      #   #   </haptic-list>
      #
      #   form.list :color, [%w[Blue blue], %w[Green green]]  do |b|
      #     b.radio_button(checked: b.value == 'blue') + b.label
      #   end
      #   # =>
      #   # <haptic-list>
      #   #   <input type="hidden" name="dummy[color]" value="" autocomplete="off">
      #   #   <haptic-list-item>
      #   #     <input is="haptic-input" type="radio" value="blue" name="dummy[color]"
      #   #       id="dummy_color_blue" checked="checked">
      #   #     <label is="haptic-label" for="dummy_color_blue">Blue</label>
      #   #   </haptic-list-item>
      #   #   <haptic-list-item>
      #   #     <input is="haptic-input" type="radio" value="green" name="dummy[color]"
      #   #      id="dummy_color_green">
      #   #     <label is="haptic-label" for="dummy_color_green">Green</label>
      #   #   </haptic-list-item>
      #   # </haptic-list>

      ##
      # :method: segmented_button
      # :call-seq: segmented_button(method, choices, options = {})
      #
      # Creates a <code><haptic-segmented-button></code> tag with the given choices.
      #
      # ==== Examples
      #
      #   form.segmented_button :color, [%w[Blue blue], %w[Green green]]
      #   # =>
      #   # <haptic-segmented-button>
      #   #   <input type="hidden" name="dummy[color]" value="" autocomplete="off">
      #   #   <div class="haptic-button-segment">
      #   #     <input type="radio" value="blue" name="dummy[color]" id="dummy_color_blue">
      #   #     <label for="dummy_color_blue">Blue</label>
      #   #   </div>
      #   #   <div class="haptic-button-segment">
      #   #     <input type="radio" value="green" name="dummy[color]" id="dummy_color_green">
      #   #     <label for="dummy_color_green">Green</label>
      #   #   </div>
      #   # </haptic-segmented-button>
      #
      #   form_builder.segmented_button(:color, [%w[Blue blue], %w[Green green]]) do |b|
      #     b.radio_button(is: nil, checked: b.value == 'blue') + b.label(is: nil)
      #   end
      #   # =>
      #   # <haptic-segmented-button>
      #   #   <input type="hidden" name="dummy[color]" value="" autocomplete="off">
      #   #   <div class="haptic-button-segment">
      #   #     <input type="radio" value="blue" name="dummy[color]" id="dummy_color_blue"
      #   #       checked="checked">
      #   #     <label for="dummy_color_blue">Blue</label>
      #   #   </div>
      #   #   <div class="haptic-button-segment">
      #   #     <input type="radio" value="green" name="dummy[color]" id="dummy_color_green">
      #   #     <label for="dummy_color_green">Green</label>
      #   #   </div>
      #   # </haptic-segmented-button>

      %i[chips list segmented_button].each do |name|
        define_method(name) do |method, choices, options = {}, &block|
          choices = choices.to_a if choices.is_a?(Hash)
          public_send(:"collection_#{name}", method, choices, :last, :first, options, &block)
        end
      end

      # ==== Example
      #
      #   form.collection_chips :color, %w[Blue Green], :downcase, :itself
      #   # =>
      #   # <input type="hidden" name="dummy[color][]" value="" autocomplete="off">
      #   # <div class="haptic-chip">
      #   #   <input type="checkbox" value="blue" name="dummy[color][]" id="dummy_color_blue">
      #   #   <label for="dummy_color_blue">Blue</label>
      #   # </div>
      #   # <div class="haptic-chip">
      #   #   <input type="checkbox" value="green" name="dummy[color][]" id="dummy_color_green">
      #   #   <label for="dummy_color_green">Green</label>
      #   # </div>
      def collection_chips(method, collection, value_method, text_method, options = {}, &block)
        collection_check_boxes(method, collection, value_method, text_method, options) do |b|
          @template.content_tag('div', class: 'haptic-chip') do
            block ? block.call(b) : b.check_box(is: nil) + b.label(is: nil)
          end
        end
      end

      # Creates a <code><haptic-list></code> tag. The list items are built by calling
      # <code>collection_radio_buttons</code> or <code>collection_check_boxes</code>
      # with the given arguments.
      #
      # ==== Options
      #
      # - <code>:multiple</code> -
      # - <code>:required</code> -
      #
      # ==== Example
      #
      #   form.collection_list :color, %w[Blue Green], :downcase, :itself
      #   # =>
      #   # <haptic-list>
      #   #   <input type="hidden" name="dummy[color]" value="" autocomplete="off">
      #   #   <haptic-list-item>
      #   #     <input is="haptic-input" type="radio" value="blue" name="dummy[color]"
      #   #       id="dummy_color_blue">
      #   #     <label is="haptic-label" for="dummy_color_blue">Blue</label>
      #   #   </haptic-list-item>
      #   #   <haptic-list-item>
      #   #     <input is="haptic-input" type="radio" value="green" name="dummy[color]"
      #   #       id="dummy_color_green">
      #   #     <label is="haptic-label" for="dummy_color_green">Green</label>
      #   #   </haptic-list-item>
      #   # </haptic-list>
      def collection_list(method, collection, value_method, text_method, options = {}, &block)
        options = options.symbolize_keys

        @template.haptic_list_tag(required: options.delete(:required) == true) do
          if options.delete(:multiple) == true
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

      # Creates a <code><haptic-segmented-button></code> tag. The button segments are built by
      # calling <code>collection_radio_buttons</code> with the given arguments.
      #
      # ==== Example
      #
      #   form.haptic_segmented_button :color, %w[Blue Green], :downcase, :itself
      #   # =>
      #   # <haptic-segmented-button>
      #   #   <input type="hidden" name="dummy[color]" value="" autocomplete="off">
      #   #   <div class="haptic-button-segment">
      #   #     <input type="radio" value="blue" name="dummy[color]" id="dummy_color_blue">
      #   #     <label for="dummy_color_blue">Blue</label>
      #   #   </div>
      #   #   <div class="haptic-button-segment">
      #   #     <input type="radio" value="green" name="dummy[color]" id="dummy_color_green">
      #   #     <label for="dummy_color_green">Green</label>
      #   #   </div>
      #   # </haptic-segmented-button>
      def collection_segmented_button(method, collection, value_method, text_method, options = {}, &block)
        @template.haptic_segmented_button_tag do
          collection_radio_buttons(method, collection, value_method, text_method, options) do |b|
            @template.content_tag('div', class: 'haptic-button-segment') do
              block ? block.call(b) : b.radio_button(is: nil) + b.label(is: nil)
            end
          end
        end
      end

      # Creates a <code><select></code> tag wrapped by a <code><haptic-dropdown-field></code>
      # tag.
      #
      # ==== Example
      #
      #   form.collection_select :color, %w[Blue Green], :downcase, :itself
      #   # =>
      #   # <haptic-dropdown-field for="dummy_color">
      #   #   <div class="haptic-field-container">
      #   #     <select name="dummy[color]" id="dummy_color">
      #   #       <option value="blue">Blue</option>
      #   #       <option value="green">Green</option>
      #   #     </select>
      #   #   </div>
      #   # </haptic-dropdown-field>
      def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
        html_options = @field_options.merge(html_options)
        field = super(
          method,
          collection,
          value_method,
          text_method,
          options,
          html_options.except(*HAPTIC_FIELD_OPTIONS)
        )
        haptic_field('dropdown', method, field, html_options)
      end

      # Creates a <code><haptic-select-dropdown</code> tag wrapped by a
      # <code>haptic-dropdown-field</code> tag.
      #
      # ==== Options
      #
      # - <code>:include_blank</code>
      # - <code>:prompt</code>
      #
      # ==== Example
      #
      #   form.collection_select_dropdown :color, %w[Blue Green], :downcase, :itself
      #   # =>
      #   # <haptic-dropdown-field for="dummy_color">
      #   #   <div class="haptic-field-container">
      #   #     <haptic-select-dropdown>
      #   #       <input autocomplete="off" type="hidden" name="dummy[color]" id="dummy_color">
      #   #       <div class="toggle haptic-field"></div>
      #   #       <div class="popover">
      #   #         <haptic-option-list>
      #   #           <haptic-option value="blue">Blue</haptic-option>
      #   #           <haptic-option value="green">Green</haptic-option>
      #   #         </haptic-option-list>
      #   #       </div>
      #   #       <div class="backdrop"></div>
      #   #     </haptic-select-dropdown>
      #   #   </div>
      #   #  </haptic-dropdown-field>
      def collection_select_dropdown(method, collection, value_method, text_method, options = {}, html_options = {})
        html_options = @field_options.merge(html_options)
        current_value = object.send(method)

        haptic_options = collection.map do |object|
          value = object.public_send(value_method)
          @template.haptic_option_tag(
            object.public_send(text_method),
            value: value,
            checked: value == current_value
          )
        end

        if options[:include_blank] == true
          haptic_options = [
            @template.haptic_option_tag(
              options[:prompt] || '',
              value: '',
              checked: current_value.blank?
            )
          ] + haptic_options
        end

        haptic_select_dropdown_field(method, haptic_options.reduce(:+), html_options)
      end

      # Creates a date field wrapped by a <code><haptic-text-field></code> tag.
      def date_field(method, options = {})
        options = @field_options.merge(options)

        haptic_field(
          'text',
          method,
          super(method, options.except(*HAPTIC_FIELD_OPTIONS)),
          options.reverse_merge(trailing_icon: 'calendar').except(:animated_label)
        )
      end

      # Creates a <code>haptic-dialog-dropdown</code> tag wrapped by a
      # <code>haptic-dropdown-field</code>.
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

      # Creates a <code><div></code> tag containing the error messages for the given attribute.
      def error_messages(method, options = {})
        error_message = error_message_for(method)
        return if error_message.blank?

        @template.content_tag(
          'div',
          error_message,
          options.merge(class: [options[:class], 'error'])
        )
      end

      # Creates a <code><select></code> tag wrapped by a <code><haptic-dropdown-field></code>
      # tag.
      #
      # ==== Example
      #
      #   form.select :color, [%w[Blue blue], %w[Green green]]
      #   # =>
      #   # <haptic-dropdown-field for="dummy_color">
      #   #   <div class="haptic-field-container">
      #   #     <select is="haptic-select" name="dummy[color]" id="dummy_color">
      #   #       <option value="blue">Blue</option>
      #   #       <option value="green">Green</option>
      #   #     </select>
      #   #   </div>
      #   # </haptic-dropdown-field>
      def select(method, choices = nil, options = {}, html_options = {}, &block)
        haptic_field('dropdown', method, super, @field_options.merge(options))
      end

      # Creates a <code><haptic-select-dropdown</code> tag wrapped by a
      # <code>haptic-dropdown-field</code> tag.
      #
      # ==== Options
      #
      # - <code>:disabled</code>
      # - <code>:onchange</code>
      # - <code>:required</code>
      # - <code>:size</code>
      # - <code>:to_top</code>
      #
      # ==== Example
      #
      #   form.select_dropdown :color, [%w[Blue blue], %w[Green green]]
      #   # =>
      #   # <haptic-dropdown-field for="dummy_color">
      #   #   <div class="haptic-field-container">
      #   #     <haptic-select-dropdown>
      #   #       <input autocomplete="off" type="hidden" name="dummy[color]" id="dummy_color">
      #   #       <div class="toggle haptic-field"></div>
      #   #         <div class="popover">
      #   #           <haptic-option-list>
      #   #             <haptic-option value="blue">Blue</haptic-option>
      #   #             <haptic-option value="green">Green</haptic-option>
      #   #           </haptic-option-list>
      #   #         </div>
      #   #       <div class="backdrop"></div>
      #   #     </haptic-select-dropdown>
      #   #   </div>
      #   # </haptic-dropdown-field>
      def select_dropdown(method, choices = nil, options = {}, &block)
        choices, options = nil, choices || {} if block
        choices = choices.to_a if choices.is_a?(Hash)
        options = @field_options.merge(options)

        haptic_options =
          if block
            @template.capture(&block)
          else
            current_value = object.send(method)

            choices&.map do |choice|
              value = choice.last
              @template.haptic_option_tag(
                choice.first,
                value: value,
                checked: value == current_value
              )
            end&.reduce(:+)
          end

        haptic_select_dropdown_field(method, haptic_options, options)
      end

      def with_field_options(options = {})
        @field_options.push(options)
        begin
          yield if block_given?
        ensure
          @field_options.pop
        end
        nil
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

      def haptic_select_dropdown_field(method, haptic_options, options = {})
        options = options.dup
        hidden_field_options = options.extract!(:disabled, :required)
        option_list_options = options.extract!(:size)
        toggle_class = ['toggle', 'haptic-field', options.delete(:class)]

        field = @template.haptic_select_dropdown_tag(options.except(*HAPTIC_FIELD_OPTIONS)) do
          hidden_field(method, hidden_field_options) +
            @template.content_tag('div', '', class: toggle_class) +
            @template.content_tag('div', class: 'popover') do
              @template.haptic_option_list_tag(haptic_options, option_list_options)
            end
        end
        haptic_field('dropdown', method, field, options)
      end

      def _field_id(method_name, namespace: @options[:namespace], index: @index)
        if respond_to?(:field_id)
          # Rails 7
          field_id(method_name, namespace: namespace, index: index)
        else
          # Rails 6
          [
            namespace,
            # ActionView::Helpers::Tags::Base#sanitized_object_name:
            @object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, '_').delete_suffix('_'),
            index,
            # ActionView::Helpers::Tags::Base#sanitized_method_name:
            method_name.to_s.delete_suffix('?')
          ].map(&:presence).compact.join('_')
        end
      end
    end
  end
end
