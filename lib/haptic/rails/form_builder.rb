# frozen_string_literal: true

module Haptic
  module Rails
    # Builds forms with haptic components.
    class FormBuilder < ActionView::Helpers::FormBuilder
      def defaults(defaults = {})
        @defaults = {} if @defaults.nil?
        @defaults.merge!(defaults) if defaults.any?
        @defaults
      end

      %i[number_field text_field].each do |name|
        define_method name do |method, options = {}|
          options = defaults.merge(options)
          haptic_text_field(method, super(method, field_options(options)), options)
        end
      end

      def select(method, choices = nil, options = {}, &block)
        options = defaults.merge(options)
        haptic_text_field(
          method,
          super(method, choices, field_options(options), &block),
          options.merge(trailing_icon: 'arrow_drop_down').except(:clear_button)
        )
      end

      def submit(value = nil, options = {})
        value, options = nil, value if value.is_a?(Hash)
        super(value, options.reverse_merge(class: 'haptic filled button with-text'))
      end

      def text_area(method, options = {})
        options = defaults.merge(options)
        haptic_text_field(
          method,
          super(method, field_options(options).merge(is: 'haptic-textarea')),
          options
        )
      end

      private

      def field_options(options)
        options.except(
          :clear_button,
          :label,
          :leading_icon,
          :style,
          :supporting_text,
          :trailing_icon
        )
      end

      def label_options(options)
        options.except(
          :clear_button,
          :label,
          :leading_icon,
          :required,
          :style,
          :supporting_text,
          :trailing_icon,
          :value
        )
      end

      def haptic_text_field(method, field, options = {})
        errors = errors(method) if options[:errors] && object&.invalid?
        supporting_text = options[:supporting_text] unless errors

        haptic_text_field =
          <<-HTML
          <haptic-text-field class="#{options[:style]}">
            #{field}
            #{leading_icon(options[:leading_icon]) if options[:leading_icon]}
            #{label(method, label_options(options)) if options[:label]}
            #{trailing_icon(options[:trailing_icon]) if options[:trailing_icon]}
            #{clear_button if options[:clear_button] && !options[:trailing_icon]}
          </haptic-text-field>
          HTML

        if errors || supporting_text
          <<-HTML.html_safe
          <div class="haptic-text-field-container">
            #{haptic_text_field}
            #{errors}
            #{supporting_text(supporting_text) if supporting_text}
          </div>
          HTML
        else
          haptic_text_field
        end.html_safe
      end

      def leading_icon(icon)
        <<-HTML.html_safe
        <div class="leading-icon material-icon">#{icon}</div>
        HTML
      end

      def trailing_icon(icon)
        <<-HTML.html_safe
        <div class="trailing-icon material-icon">#{icon}</div>
        HTML
      end

      def clear_button
        <<-HTML.html_safe
        <button class="haptic flat circular material-icon">close</button>
        HTML
      end

      def supporting_text(text)
        <<-HTML.html_safe
        <div class="haptic supporting-text">#{text}</div>
        HTML
      end

      def errors(method)
        full_messages = object&.errors&.full_messages_for(method)
        return if full_messages.blank?

        <<-HTML.html_safe
        <div class="haptic errors">
          #{full_messages.join('. ')}.
        </div>
        HTML
      end
    end
  end
end
