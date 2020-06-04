# frozen_string_literal: true

class Environment
  attr_reader :values

  def initialize
    @values = {}
  end

  def assign(token, value)
    if values.has_key?(token.lexeme)
      values[token.lexeme] = value
      return value
    end

    raise RloxRuntimeError.new(token, "Undefined variable #{token.lexeme}.")
  end

  def define(name, value)
    values[name] = value
  end

  def get(token)
    return values[token.lexeme] if values.has_key?(token.lexeme)

    raise RloxRuntimeError.new(token, "Undefined variable #{token.lexeme}.")
  end
end
