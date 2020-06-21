# frozen_string_literal: true

class RloxRuntimeError < RuntimeError
  attr_reader :token
  def initialize(token, msg = nil)
    @token = token
    super(msg)
  end
end
