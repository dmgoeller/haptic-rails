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

      %i[number_field text_area text_field].each do |name|
        element_name = "haptic-#{name == :text_area ? 'textarea' : 'input'}"

        define_method name do |method, options = {}|
          options = defaults.merge(options)
          field = super(method, field_options(options, is: element_name))
          return field unless HAPTIC_TEXT_FIELD_OPTIONS.any? { |key| options.key? key }

          haptic_text_field(method, field, options)
        end
      end

      def check_box(method, options = {}, checked_value = '1', unchecked_value = '0')
        options = options.reverse_merge(class: [options[:class], defaults[:class], 'haptic'].join(' '))
        super(method, options, checked_value, unchecked_value)
      end

      def defaults(defaults = {})
        @defaults = {} if @defaults.nil?
        @defaults.merge!(defaults) if defaults.any?
        @defaults
      end

      def errors(method, options = {})
        full_messages = object&.errors&.full_messages_for(method)
        return if full_messages.blank?

        <<~HTML.html_safe
          <div class="#{['error', options[:class]].join(' ')}">
            #{full_messages.join('. ').delete_suffix('.')}.
          </div>
        HTML
      end

      def search_field(method, options = {})
        text_field(method, options.reverse_merge(leading_icon: 'search', clear_button: true))
      end

      def select(method, choices = nil, options = {}, html_options = {}, &block)
        options = defaults.except(:class).merge(options)
        html_options = html_options.merge(
          class: [html_options[:class], defaults[:class], 'haptic'].compact.join(' ')
        )
        haptic_text_field(
          method,
          super(method, choices, field_options(options), html_options, &block),
          options.merge(trailing_icon: 'arrow_drop_down').except(:clear_button)
        )
      end

      def submit(value = nil, options = {})
        value, options = nil, value if value.is_a?(Hash)
        super(value, options.merge(is: 'haptic-input'))
      end

      private

      def field_options(options, is: nil)
        options.merge(is: is).except(*HAPTIC_TEXT_FIELD_OPTIONS)
      end

      def haptic_text_field(method, field, options = {})
        # Don't call :valid? or :invalid? here to prevent errors on new records
        errors = object&.errors&.include?(method)

        attributes = [
          ('animated' if options[:animated]),
          ('focus-indicator' if options[:focus_indicator]),
          ('with-errors' if errors)
        ].compact.join(' ')

        trailing_icon = trailing_icon(options[:trailing_icon]) if options[:trailing_icon]
        trailing_icon ||= trailing_icon('error', class: 'error') if options[:error_icon] && errors

        <<~HTML.html_safe
          <haptic-text-field #{attributes}>
            <div class="container">
              #{field}
              #{tool_button('close', class: 'clear-button') if options[:clear_button]}
              #{haptic_text_field_label(method, options) if options[:label]}
              #{icon(options[:leading_icon], class: 'leading-icon') if options[:leading_icon]}
              #{trailing_icon}
            </div>
            #{errors(method, class: 'supporting-text') if options[:error_messages] && errors}
            #{supporting_text(options[:supporting_text]) if options[:supporting_text]}
          </haptic-text-field>
        HTML
      end

      def haptic_text_field_label(method, options = {})
        args = [:label, method]
        args << options[:label] unless options[:label] == true
        args << { data: { animated: '' } } if options[:animated]

        send(*args)
      end

      def supporting_text(text)
        <<~HTML.html_safe
          <div class="supporting-text">#{text}</div>
        HTML
      end

      def trailing_icon(icon, options = {})
        icon(icon, options.merge(class: ['trailing-icon', options[:class]].compact.join(' ')))
      end

      # ---

      def icon(icon, options = {})
        <<~HTML.html_safe
          <div class="material-icon #{options[:class]}">#{icon}</div>
        HTML
      end

      def tool_button(icon, options = {})
        <<~HTML.html_safe
          <div class="haptic toolbutton material-icon #{options[:class]}">#{icon}</div>
        HTML
      end
    end
  end
end
