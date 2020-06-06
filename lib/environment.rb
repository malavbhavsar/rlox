# frozen_string_literal: true

class Environment
  attr_reader :values, :enclosing

  def initialize(enclosing = nil)
    @values = {}
    @enclosing = enclosing
  end

  def assign(token, value)
    if values.has_key?(token.lexeme)
      values[token.lexeme] = value
      return value
    end

    unless enclosing.nil?
      enclosing.assign(token, value)
      return nil # necessary?
    end

    raise RloxRuntimeError.new(token, "Undefined variable #{token.lexeme}.")
  end

  def define(name, value)
    values[name] = value
  end

  def get(token)
    return values[token.lexeme] if values.has_key?(token.lexeme)

    return enclosing.get(token) unless enclosing.nil?

    raise RloxRuntimeError.new(token, "Undefined variable #{token.lexeme}.")
  end
end
