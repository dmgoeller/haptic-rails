# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module MenuHelper
        # :call-seq: haptic_dropdown_menu(**options, &block)
        #
        # Creates a haptic dropdown menu. If a block is given, it is called with an instance
        # of DropdownMenuBuilder as argument.
        #
        # ==== Options
        #
        # - <code>:open_to_top</code> - If is set to <code>true</code>, the menu
        #   pops up to top instead of to bottom.
        #
        # ==== Example
        #
        #   haptic_dropdown_menu do |dropdown|
        #     dropdown.menu do |menu|
        #       menu.item('Duplicate', href: '/duplicate')
        #     end
        #   end
        #   # =>
        #   # <haptic-dropdown-menu>
        #   #   <haptic-menu class="popover">
        #   #     <a is="haptic-menu-item" href="/duplicate">Duplicate</a>
        #   #   </haptic-menu>
        #   #.  <div class="backdrop"></div>
        #   # </haptic-dropdown-menu>
        def haptic_dropdown_menu(**options)
          haptic_dropdown_menu_tag(**options) do
            yield DropdownMenuBuilder.new(self) if block_given?
          end
        end
      end
    end
  end
end
