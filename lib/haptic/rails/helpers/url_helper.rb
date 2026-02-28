# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module UrlHelper
        # Calls <code>link_to</code> with the following defaults:
        #
        # - <code>is: 'haptic-nav-item'</code>
        # - <code>rel: 'next'</code>
        # - <code>'active-on': '_pathname'</code>
        def haptic_nav_item_to(name = nil, options = nil, html_options = nil, &block)
          defaults = {
            is: 'haptic-nav-item',
            rel: 'next',
            'active-on': '_pathname'
          }
          if block_given?
            options = defaults.merge(options || {})
          else
            html_options = defaults.merge(html_options || {})
          end
          link_to(name, options, html_options, &block)
        end
      end
    end
  end
end
