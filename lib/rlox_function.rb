# frozen_string_literal: true

class RloxFunction < RloxCallable
  attr_reader :declaration

  def initialize(declaration)
    @declaration = declaration
  end

  def arity
    declaration.parameters.size
  end

  def call(interpreter, arguments)
    environment = Environment.new(interpreter.globals)
    declaration.parameters.each_with_index do |parameter, index|
      environment.define(parameter.lexeme, arguments[index])
    end

    begin
      interpreter.execute_block(declaration.body, environment)
    rescue Return => e
      return e.value
    end

    nil
  end

  def to_s
    "<fn #{declaration.name.lexeme}>"
  end
end
