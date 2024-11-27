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

      def errors(method)
        full_messages = object&.errors&.full_messages_for(method)
        return if full_messages.blank?

        <<-HTML.html_safe
        <div class="errors">
          #{full_messages.join('. ')}.
        </div>
        HTML
      end

      %i[number_field text_field].each do |name|
        define_method name do |method, options = {}|
          options = defaults.merge(options)
          haptic_text_field(method, super(method, field_options(options)), options)
        end
      end

      def search_field(method, options = {})
        text_field(method, options.reverse_merge(leading_icon: 'search', clear_button: true))
      end

      def select(method, choices = nil, options = {}, html_options = {}, &block)
        options = defaults.merge(options)
        haptic_text_field(
          method,
          super(method, choices, field_options(options), html_options, &block),
          options.merge(trailing_icon: 'arrow_drop_down').except(:clear_button)
        )
      end

      # def submit(value = nil, options = {})
      #  value, options = nil, value if value.is_a?(Hash)
      #  super(value, options.reverse_merge(class: 'haptic filled button with-text'))
      # end

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

      def haptic_text_field(method, field, options = {})
        haptic_text_field =
          <<-HTML
          <haptic-text-field class="#{options[:style]}">
            #{field}
            #{field_label(method, options[:label]) if options[:label]}
            #{leading_icon(options[:leading_icon]) if options[:leading_icon]}
            #{trailing_icon(options[:trailing_icon]) if options[:trailing_icon]}
            #{clear_button if options[:clear_button]}
          </haptic-text-field>
          HTML

        errors = errors(method) if options[:errors] && object&.errors
        supporting_text = options[:supporting_text]

        if errors || supporting_text
          <<-HTML
          <haptic-field-container>
            #{haptic_text_field}
            #{errors}
            #{supporting_text(supporting_text) if supporting_text}
          </haptic-field-container>
          HTML
        else
          haptic_text_field
        end.html_safe
      end

      def field_label(method, label)
        label == true ? label(method) : label(method, label)
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
        <button class="circular material-icon">close</button>
        HTML
      end

      def supporting_text(text)
        <<-HTML.html_safe
        <div class="supporting-text">#{text}</div>
        HTML
      end
    end
  end
end
