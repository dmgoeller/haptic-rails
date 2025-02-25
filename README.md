# Haptic Rails

Haptic Rails provides a set of Web Components inspired by Material Design. It includes a
FormBuilder to easily use these components in a Rails application.

See [Haptic components](https://dmgoeller.github.io/haptic-rails) for details about the
available components.

## Installation

Add the following line to `Gemfile` and run `bundle install`.

```ruby
gem 'haptic-rails', git: 'https://github.com.dmgoeller/haptic-rails', branch: 'main'
```

To use all features a polyfill for the Web Components API covering customized built-in
elements have to be added to the application, for example
[ungap/custom-elements](https://github.com/ungap/custom-elements).

## Configuration

### Sass variables

- `$haptic-high-density`
- `$haptic-dark-mode`
- `$haptic-popover-z-index`

#### Colors

- `$haptic-light-primary-color`
- `$haptic-primary-color`
- `$haptic-dark-primary-color`
- `$haptic-light-secondary-color`
- `$haptic-secondary-color`
- `$haptic-dark-secondary-color`
- `$haptic-light-green`
- `$haptic-green`
- `$haptic-dark-green`
- `$haptic-light-red`
- `$haptic-red`
- `$haptic-dark-red`
- `$haptic-light-gray`
- `$haptic-gray`
- `$haptic-dark-gray`
- `$haptic-black`

#### Borders

- `$haptic-button-border-radius`
- `$haptic-field-border-radius`

### Icon Builder

```ruby
# /config/initializers/haptic_rails.rb

Haptic::Rails.configuration.icon_builder = lambda do |name, options = {}|
  builder = options[:builder]

  builder.content_tag 'div', name, class: ['custom-icon-class', options[:class]]
end
```
