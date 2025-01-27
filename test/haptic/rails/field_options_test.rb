# frozen_string_literal: true

require 'test_helper'

module Haptic
  module Rails
    class FieldOptionsTest < Minitest::Test
      def test_merge
        field_options = FieldOptions.new(foo: 'bar')
        assert_equal(
          { foo: 'bar', bar: 'foo' },
          field_options.merge(bar: 'foo')
        )
        assert_equal(
          { foo: 'foo' },
          field_options.merge(foo: 'foo')
        )
      end

      def test_reverse_merge
        field_options = FieldOptions.new(foo: 'bar')
        assert_equal(
          { foo: 'bar', bar: 'foo' },
          field_options.reverse_merge(bar: 'foo')
        )
        assert_equal(
          { foo: 'bar' },
          field_options.reverse_merge(foo: 'foo')
        )
      end

      def test_push
        field_options = FieldOptions.new(foo: 'bar')
        result = field_options.push(bar: 'foo')
        assert_equal(field_options, result)
        assert_equal({ foo: 'bar', bar: 'foo' }, field_options.options)
      end

      def test_pop
        field_options = FieldOptions.new
        field_options.push(foo: 'bar')
        result = field_options.pop
        assert_equal({ foo: 'bar' }, result)
        assert_equal({}, field_options.options)
      end
    end
  end
end
