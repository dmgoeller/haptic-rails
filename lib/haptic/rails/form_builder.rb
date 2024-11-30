# frozen_string_literal: true

module Haptic
  module Rails
    # Builds forms with haptic components.
    class FormBuilder < ActionView::Helpers::FormBuilder
      HAPTIC_TEXT_FIELD_OPTIONS = %i[
        animated
        clear_button
        errors
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

      def defaults(defaults = {})
        @defaults = {} if @defaults.nil?
        @defaults.merge!(defaults) if defaults.any?
        @defaults
      end

      def errors(method, options = {})
        full_messages = object&.errors&.full_messages_for(method)
        return if full_messages.blank?

        <<-HTML.html_safe
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
        <<-HTML.html_safe
        <haptic-text-field #{haptic_text_field_attributes(method, options)}>
          #{field}
          #{haptic_text_field_label(method, options[:label]) if options[:label]}
          #{leading_icon(options[:leading_icon]) if options[:leading_icon]}
          #{trailing_icon(options[:trailing_icon]) if options[:trailing_icon]}
          #{clear_button if options[:clear_button]}
          #{errors(method, class: 'supporting-text') if options[:errors]}
          #{supporting_text(options[:supporting_text]) if options[:supporting_text]}
        </haptic-text-field>
        HTML
      end

      def haptic_text_field_attributes(method, options = {})
        [
          ('data-animated' if options[:animated]),
          ('data-with-errors' if object&.errors&.include?(method))
        ].compact.join(' ')
      end

      def haptic_text_field_label(method, label)
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
        <div class="clear-button material-icon">close</div>
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
