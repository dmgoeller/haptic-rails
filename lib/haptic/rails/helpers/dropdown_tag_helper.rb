# frozen_string_literal: true

module Haptic
  module Rails
    module Helpers
      module DropdownTagHelper
        ##
        # :method: haptic_dropdown_dialog_tag
        # :call-seq:
        #   haptic_dropdown_dialog_tag(content = nil, **options)
        #   haptic_dropdown_dialog_tag(**options, &block)
        #
        # Creates a <code><haptic-dropdown-dialog></code> tag.
        #
        # ==== Options
        #
        # - <code>:open_to_top</code> - If is set to <code>true</code>, the dialog pops up
        #   to top instead of to bottom.
        #
        # ==== Examples
        #
        #   haptic_dropdown_dialog_tag(tag.div(class: 'toggle') + tag.div(class: 'popover'))
        #   # =>
        #   # <haptic-dropdown-dialog>
        #   #   <div class="toggle"></div>
        #   #   <div class="popover"></div>
        #   #   <div class="backdrop"></div>
        #   # </haptic-dropdown-dialog>
        #
        #   haptic_dropdown_dialog_tag(
        #     tag.div(class: 'toggle') + tag.div(class: 'popover'),
        #     open_to_top: true
        #   )
        #   # =>
        #   # <haptic-dropdown-dialog open-to-top>
        #   #   <div class="toggle"></div>
        #   #   <div class="popover"></div>
        #   #   <div class="backdrop"></div>
        #   # </haptic-dropdown-dialog>

        ##
        # :method: haptic_dropdown_menu_tag
        # :call-seq:
        #   haptic_dropdown_menu_tag(content = nil, **options)
        #   haptic_dropdown_menu_tag(**options, &block)
        #
        # Creates a <code><haptic-dropdown-menu></code> tag.
        #
        # ==== Options
        #
        # - <code>:open_to_top</code> - If is set to <code>true</code>, the menu pops up
        #   to top instead of to bottom.
        #
        # ==== Examples
        #
        #   haptic_dropdown_menu_tag(tag.div(class: 'toggle') + tag.div(class: 'popover'))
        #   # =>
        #   # <haptic-dropdown-menu>
        #   #   <div class="toggle"></div>
        #   #   <div class="popover"></div>
        #   #   <div class="backdrop"></div>
        #   # </haptic-dropdown-menu>
        #
        #   haptic_dropdown_menu_tag(
        #     tag.div(class: 'toggle') + tag.div(class: 'popover'),
        #     open_to_top: true
        #   )
        #   # =>
        #   # <haptic-dropdown-menu open-to-top>
        #   #   <div class="toggle"></div>
        #   #   <div class="popover"></div>
        #   #   <div class="backdrop"></div>
        #   # </haptic-dropdown-menu>

        ##
        # :method: haptic_select_dropdown_tag
        # :call-seq:
        #   haptic_select_dropdown_tag(content = nil, **options)
        #   haptic_select_dropdown_tag(**options, &block)
        #
        # Creates a <code><haptic-select-dropdown></code> tag.
        #
        # ==== Example
        #
        #   haptic_select_dropdown(tag.div(class: 'toggle') + tag.div(class: 'popover'))
        #   # =>
        #   # <haptic-select-dropdown>
        #   #   <div class="toggle"></div>
        #   #   <div class="popover"></div>
        #   #   <div class="backdrop"></div>
        #   # </haptic-select-dropdown>

        %w[
          haptic-dropdown
          haptic-dropdown-dialog
          haptic-dropdown-menu
          haptic-select-dropdown
        ].each do |tag_name|
          define_method(:"#{tag_name.underscore}_tag") do |content = nil, **options, &block|
            content = capture(&block) if block
            content = (content || '').html_safe unless content&.html_safe?

            if tag_name.in?(%w[haptic-dropdown-dialog haptic-dropdown-menu]) &&
               options.delete(:open_to_top)
              options[:'open-to-top'] ||= ''
            end

            tag.send(tag_name, content + tag.div(class: 'backdrop'), **options)
          end
        end
      end
    end
  end
end
