# frozen_string_literal: true

module Haptic
  module Rails
    class Builder < SimpleDelegator
      def initialize(template, defaults)
        super(template)
        @defaults = defaults
      end

      %i[number_field text_field].each do |name|
        define_method name do |object_name, method, options = {}|
          super(object_name, method, tag_options(options, is: 'haptic-input'))
        end
      end

      def check_box(object_name, method, options = {}, checked_value = '1', unchecked_value = '0')
        return super if options[:class]&.include?('switch') # TODO

        super(object_name, method, tag_options(options, is: 'haptic-input'), checked_value, unchecked_value)
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
        content_or_options = content_or_options.merge(is: 'haptic-label') if content_or_options.is_a?(Hash)
        options = options.merge(is: 'haptic-label') if options.is_a?(Hash)
        ActionView::Helpers::Tags::Label.new(object_name, method, self, content_or_options, options).render(&block)
      end

      def radio_button(object_name, method, tag_value, options = {})
        super(object_name, method, tag_value, tag_options(options, is: 'haptic-input'))
      end

      def select(object_name, method, choices = nil, options = {}, html_options = {}, &block)
        super(object_name, method, choices, options, tag_options(html_options, is: 'haptic-select'), &block)
      end

      def submit_tag(value = 'Save changes', options = {})
        super(value, options.merge(is: 'haptic-input'))
      end

      def text_area(object_name, method, options = {})
        super(object_name, method, tag_options(options, is: 'haptic-textarea'))
      end

      private

      def css_class(*classes)
        classes.filter_map { |c| c&.split(' ') }.flatten.uniq.join(' ')
      end

      def tag_options(options, is: nil)
        options.merge(is: is, class: css_class(options[:class], defaults[:class]))
      end
    end
  end
end
