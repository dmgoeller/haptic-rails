# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module MenuHelper
        # Creates a <code><haptic-dropdown-menu></code> tag.
        #
        # # ==== Options
        #
        # - <code>:open_to_top</code> - If is <code>true</code>, the menu
        #   pops up to top instead of to bottom.
        #
        # # ==== Example
        #
        #   haptic_dropdown_menu do |dropdown|
        #     dropdown.menu do |menu|
        #       menu.item 'Duplicate', href: '/duplicate'
        #       menu.item 'Delete', href: '/delete'
        #     end
        #   end
        def haptic_dropdown_menu(options = {})
          haptic_dropdown_menu_tag(options) do
            yield DropdownMenuBuilder.new(self) if block_given?
          end
        end
      end
    end
  end
end
