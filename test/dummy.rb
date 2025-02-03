# frozen_string_literal: true

class Dummy
  include ActiveModel::Model
  extend ActiveModel::Naming

  attr_accessor :color, :date, :name
end
