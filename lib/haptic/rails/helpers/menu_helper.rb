# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module MenuHelper
        def haptic_dropdown_menu(options = {})
          haptic_dropdown_menu_tag(options) do
            yield DropdownMenuBuilder.new(self) if block_given?
          end
        end
      end
    end
  end
end
