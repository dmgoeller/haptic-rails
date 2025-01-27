# frozen_string_literal: true

require 'minitest'

# SimpleCov
require 'simplecov'

SimpleCov.start do
  add_filter '/test/'
  enable_coverage :branch
end

# Copied form SimpleCov's Minitest plug-in:
SimpleCov.external_at_exit = true
Minitest.after_run do
  SimpleCov.at_exit_behavior
end

# Active Support
require 'active_support'
require 'active_support/core_ext/object'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/array'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'

# Active Model
require 'active_model'

# Action View
require 'action_view'

module Rails
  class Engine; end
end

# Dummies
require 'dummy'

# This gem
require 'haptic-rails'

# Pry
require 'pry'

# Start Minitest
require 'minitest/stub_any_instance'
require 'minitest/autorun'
