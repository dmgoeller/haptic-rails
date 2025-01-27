# frozen_string_literal: true

require 'minitest/test_task'

Minitest::TestTask.create(:test) do |minitest|
  minitest.libs << 'test'
  minitest.libs << 'lib'
  minitest.warning = true
  minitest.test_globs = ['test/**/*_test.rb']
end
