# frozen_string_literal: true

class Return < RuntimeError
  attr_reader :value

  def initialize(value)
    @value = value
  end
end
