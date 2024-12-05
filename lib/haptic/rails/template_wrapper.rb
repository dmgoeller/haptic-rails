# frozen_string_literal: true

module Haptic
  module Rails
    class TemplateWrapper < SimpleDelegator
      def initialize(template, builder)
        super(template)
        @builder = builder
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
        content_or_options, options =
          if content_or_options.is_a?(Hash)
            [content_or_options.merge(is: 'haptic-label'), options]
          else
            [content_or_options, options.merge(is: 'haptic-label')]
          end
        super(object_name, method, content_or_options, options, &block)
      end

      def radio_button(object_name, method, tag_value, options = {})
        super(object_name, method, tag_value, tag_options(options, is: 'haptic-input'))
      end

      def inspect
        "<##{self.class.name} #{super}>"
      end

      private

      def tag_options(options, is: nil)
        css_classes = [options[:class], @builder.defaults[:class]].compact.join(' ')
        options.merge(is: is, class: css_classes)
      end
    end
  end
end
