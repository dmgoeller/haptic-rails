# frozen_string_literal: true

require_relative 'helpers/form_helper'
require_relative 'helpers/form_options_helper'
require_relative 'helpers/icon_helper'
require_relative 'helpers/nav_helper'
require_relative 'helpers/tag_helper'

ActiveSupport.on_load(:action_view) do
  include Haptic::Rails::Helpers::FormHelper
  include Haptic::Rails::Helpers::FormOptionsHelper
  include Haptic::Rails::Helpers::IconHelper
  include Haptic::Rails::Helpers::NavHelper
  include Haptic::Rails::Helpers::TagHelper
end
