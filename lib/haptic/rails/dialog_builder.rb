# frozen_string_literal: true

module Haptic
  module Rails
    class DialogBuilder
      def initialize(builder) # :nodoc:
        @builder = builder
      end

      # Creates the dialog header.
      #
      # ==== Example
      #
      #   header(
      #     tag.div('Headline', class: 'headline') +
      #       tag.div('Helper text', class: 'supporting-text')
      #   )
      #   # =>
      #   # <div class="dialog-header">
      #   #   <div class="headline">Headline</div>
      #   #   <div class="supporting-text">Helper text</div>
      #   # </div>
      def header(content = nil, **options, &block)
        @builder.tag.div(
          content,
          **options.merge(class: ['dialog-header', options[:class]]),
          &block
        )
      end

      # Adds a dialog segment.
      def segment(legend = nil, **options, &block)
        @builder.tag.div(
          if legend.present?
            @builder.tag.div(legend, class: 'legend')
          else
            ''.html_safe
          end + (@builder.capture(&block) if block),
          **options.merge(class: ['dialog-segment', options[:class]])
        )
      end
    end
  end
end
