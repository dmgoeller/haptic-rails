# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'haptic-rails'
  s.version = '0.1'
  s.summary = 'Haptic Rails'
  s.license = 'MIT'
  s.authors = ['Denis Göller']
  s.email = 'denis@dmgoeller.de'
  s.files = Dir['lib/**/*.rb']
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.7.0'
  s.homepage = 'https://github.com/dmgoeller/haptic-rails'
  s.metadata = {
    'homepage_uri' => 'https://github.com/dmgoeller/haptic-rails'
  }
  s.add_dependency 'rails'
end
