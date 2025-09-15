# frozen_string_literal: true

module Haptic
  module Rails
    class Builder < SimpleDelegator # :nodoc:
      def initialize(template, field_options)
        super(template)
        @field_options = field_options
      end

      %i[date_field datetime_field datetime_local_field email_field file_field month_field number_field
         password_field phone_field search_field telephone_field text_field week_field].each do |name|
        define_method name do |object_name, method, options = {}|
          super(object_name, method, field_options(options, is: 'haptic-input'))
        end
      end

      def button_tag(content_or_options = nil, options = nil, &block)
        if content_or_options.is_a?(Hash)
          content_or_options = content_or_options.reverse_merge(is: 'haptic-button')
        else
          options = (options || {}).reverse_merge(is: 'haptic-button')
        end
        super(content_or_options, options, &block)
      end

      def check_box(object_name, method, options = {}, checked_value = '1', unchecked_value = '0')
        super(object_name, method, field_options(options, is: 'haptic-input'), checked_value, unchecked_value)
      end

      def collection_check_boxes(object_name, method, collection, value_method, text_method, options = {}, html_options = {}, &block)
        ActionView::Helpers::Tags::CollectionCheckBoxes.new(
          object_name, method, self, collection, value_method, text_method, options, html_options
        ).render(&block)
      end

      def collection_radio_buttons(object_name, method, collection, value_method, text_method, options = {}, html_options = {}, &block)
        ActionView::Helpers::Tags::CollectionRadioButtons.new(
          object_name, method, self, collection, value_method, text_method, options, html_options
        ).render(&block)
      end

      def label(object_name, method, content_or_options = nil, options = nil, &block)
        if content_or_options.is_a?(Hash)
          content_or_options = content_or_options.reverse_merge(is: 'haptic-label')
        else
          options = (options || {}).reverse_merge(is: 'haptic-label')
        end
        ActionView::Helpers::Tags::Label.new(object_name, method, self, content_or_options, options).render(&block)
      end

      def radio_button(object_name, method, tag_value, options = {})
        super(object_name, method, tag_value, field_options(options, is: 'haptic-input'))
      end

      def select(object_name, method, choices = nil, options = {}, html_options = {}, &block)
        super(object_name, method, choices, options, field_options(html_options, is: 'haptic-select'), &block)
      end

      def submit_tag(value = 'Save changes', options = {})
        super(value, options.reverse_merge(is: 'haptic-input'))
      end

      def text_area(object_name, method, options = {})
        super(object_name, method, field_options(options, is: 'haptic-textarea'))
      end

      private

      def field_options(options, is: nil)
        classes = [@field_options[:class], options[:class]].flatten.compact

        options.dup.tap do |field_options|
          field_options[:class] = classes if classes.any?
          field_options[:is] = is unless options.key?(:is)
        end
      end
    end
  end
end
