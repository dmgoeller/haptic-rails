# frozen_string_literal: true

require_relative 'helpers/dialog_helper'
require_relative 'helpers/dropdown_tag_helper'
require_relative 'helpers/field_tag_helper'
require_relative 'helpers/form_helper'
require_relative 'helpers/form_options_helper'
require_relative 'helpers/icon_tag_helper'
require_relative 'helpers/menu_helper'
require_relative 'helpers/nav_helper'
require_relative 'helpers/table_helper'

ActiveSupport.on_load(:action_view) do
  include Haptic::Rails::Helpers::DialogHelper
  include Haptic::Rails::Helpers::DropdownTagHelper
  include Haptic::Rails::Helpers::FieldTagHelper
  include Haptic::Rails::Helpers::FormHelper
  include Haptic::Rails::Helpers::FormOptionsHelper
  include Haptic::Rails::Helpers::IconTagHelper
  include Haptic::Rails::Helpers::MenuHelper
  include Haptic::Rails::Helpers::NavHelper
  include Haptic::Rails::Helpers::TableHelper
end
