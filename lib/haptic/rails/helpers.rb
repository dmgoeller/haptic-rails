# frozen_string_literal: true

require_relative 'helpers/button_helper'
require_relative 'helpers/icon_helper'

ActiveSupport.on_load(:action_view) do
  include Haptic::Rails::Helpers::ButtonHelper
end
