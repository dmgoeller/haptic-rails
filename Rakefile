# frozen_string_literal: true

require 'minitest/test_task'
require 'rdoc/task'

Minitest::TestTask.create(:test) do |minitest|
  minitest.libs << 'test'
  minitest.libs << 'lib'
  minitest.warning = true
  minitest.test_globs = ['test/**/*_test.rb']
end

RDoc::Task.new do |rdoc|
  rdoc.main = 'README.md'
  rdoc.rdoc_dir = 'rdoc'
  rdoc.rdoc_files.include('lib') #, 'CHANGELOG.md', 'LICENSE', 'README.md')
end
