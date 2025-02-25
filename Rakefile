# frozen_string_literal: true

require 'fileutils'
require 'minitest/test_task'
require 'rdoc/task'

task :prepare_build do
  FileUtils.mkpath('./_build/_sass')
  FileUtils.copy_entry('./docs', './_build')
  FileUtils.copy_entry('./vendor/assets/javascripts', './_build')
  FileUtils.copy_entry('./vendor/assets/images', './_build')
  FileUtils.copy_entry('./vendor/assets/stylesheets', './_build/_sass')
end

Minitest::TestTask.create(:test) do |minitest|
  minitest.libs << 'test'
  minitest.libs << 'lib'
  minitest.warning = true
  minitest.test_globs = ['test/**/*_test.rb']
end

RDoc::Task.new do |rdoc|
  rdoc.main = 'README.md'
  rdoc.rdoc_dir = 'rdoc'
  rdoc.rdoc_files.include('lib') # , 'CHANGELOG.md', 'LICENSE', 'README.md')
end
