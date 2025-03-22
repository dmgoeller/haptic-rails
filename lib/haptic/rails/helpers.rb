# frozen_string_literal: true

require_relative 'helpers/form_helper'
require_relative 'helpers/form_tag_helper'
require_relative 'helpers/icon_helper'

ActiveSupport.on_load(:action_view) do
  include Haptic::Rails::Helpers::FormHelper
  include Haptic::Rails::Helpers::FormTagHelper
  include Haptic::Rails::Helpers::IconHelper
end
