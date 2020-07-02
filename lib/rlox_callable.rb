# frozen_string_literal: true

class RloxCallable
  def arity
    raise NotImplementedError
  end

  def call(interpreter, arguments)
    raise NotImplementedError
  end
end
