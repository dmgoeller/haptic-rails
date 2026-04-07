# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module NavHelper
        # :call-seq: haptic_nav(**options, &block)
        #
        # Creates a haptic nav. Passes an instance of NavBuilder to the block.
        #
        # ==== Options
        #
        # - <code>:defaults</code> - The default options to be applied to all nav items.
        #
        # ==== Example
        #
        #   haptic_nav(defaults: { rel: 'next' }) do |nav|
        #     nav.item('Home', href: '/')
        #   end
        #   # =>
        #   # <nav is="haptic-nav">
        #   #   <a is="haptic-nav-item" href="/" active-on="_pathname" rel="next">Home</a>
        #   # </nav>
        def haptic_nav(**options)
          options = options.merge(is: 'haptic-nav')
          defaults = options.delete(:defaults) || {}

          tag.nav(**options) do
            yield NavBuilder.new(self, **defaults) if block_given?
          end
        end
      end
    end
  end
end
